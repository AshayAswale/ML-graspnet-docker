FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# Setting environment PATH
ENV PATH=/usr/local/cuda-10.0/bin:/usr/local/cuda-10.0/NsightCompute-2019.1${PATH:+:${PATH}}

# Installing necessary packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y python3-rtree wget python3-opencv freeglut3-dev \
                sudo x11-apps mesa-utils nvidia-driver-455 git libxt-dev libxext-dev \
                libgl-dev python3.6 python3-pip

# Creating the user (without the user, it will not work)
RUN export uid=1000 gid=1000 && \
  mkdir -p /home/ashay && \
  echo "ashay:x:${uid}:${gid}:ashay,,,:/home/ashay:/bin/bash" >> /etc/passwd && \
  echo "ashay:x:${uid}:" >> /etc/group && \
  echo "ashay ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ashay && \
  chmod 0440 /etc/sudoers.d/ashay && \
  chown ${uid}:${gid} -R /home/ashay
USER ashay
WORKDIR /home/ashay
ENV HOME /home/ashay

# Downloading the git packages
RUN cd $HOME && git clone https://github.com/jsll/pytorch_6dof-graspnet.git
RUN cd $HOME && git clone https://github.com/erikwijmans/Pointnet2_PyTorch.git

# Installing pip packages
# For some reason, demo.main will fail without sudo. Do not remove.
RUN sudo pip3 install torch==1.4.0 torchvision==0.5.0 -f \<https://download.pytorch.org/whl/torch_stable.html\>
RUN cd ~/Pointnet2_PyTorch && sudo pip3 install -r requirements.txt

COPY packages_pip.txt /tmp/packages_pip.txt
RUN test ! -s /tmp/packages_pip.txt || \
    sudo pip3 install -r /tmp/packages_pip.txt
RUN sudo pip3 install --upgrade pip && sudo pip3 install PyQt5

# Installing apt packages
COPY packages_apt.txt /tmp/packages_apt.txt
RUN test ! -s /tmp/packages_apt.txt || \
    (sudo apt update && sudo apt install --no-install-recommends -y \
        $(sed 's/#.*$//g;s/\n//g' /tmp/packages_apt.txt) \
    && sudo rm -rf /var/lib/apt/lists/*)
