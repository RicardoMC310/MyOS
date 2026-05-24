#!/bin/zsh

docker run -it \
    --rm -v $(pwd):/workspace \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -p 1234:1234 \
    monnyos-dev:latest