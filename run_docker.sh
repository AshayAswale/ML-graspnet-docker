docker run \
        -it --gpus all \
        --rm \
        -e DISPLAY=${DISPLAY} \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        --device /dev/dri \
        --privileged \
        graspnet_docker