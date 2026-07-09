#!/bin/bash

export set=false
export IMG_NAME="ros_jazzy_base_image"
export REGISTRY="ghcr.io/screamlab"
export TODAY=$(date +%Y%m%d)
export DOCKER_CLI_EXPERIMENTAL=enabled

usage() {
    echo "Usage: $0 -j <threads>"
    exit 0
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -j)
            threads="$2"
            set=true
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if ! [[ "$threads" =~ ^[0-9]+$ ]] && ! [[ "$threads" =~ ^[-][0-9]+$ ]]; then
    echo "$0 - $threads is NOT an integer. Ignoring."
    set=false
fi

if [ "$set" = true ]; then
    docker build \
        --tag $REGISTRY/$IMG_NAME:latest \
        --tag $REGISTRY/$IMG_NAME:$TODAY \
        --build-arg THREADS=$threads \
        -f ./Dockerfile .
else
    docker build \
        --tag $REGISTRY/$IMG_NAME:latest \
        --tag $REGISTRY/$IMG_NAME:$TODAY \
        -f ./Dockerfile .
fi
