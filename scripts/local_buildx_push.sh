#!/bin/bash

export IMG_NAME="ros_jazzy_base_image"
export REGISTRY="ghcr.io/screamlab"
export TAG=$(date +%Y%m%d)
export DOCKER_CLI_EXPERIMENTAL=enabled

usage() {
    echo "Usage: $0 -t <tag>"
    exit 0
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -t)
            TAG="$2"
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

echo "Using tag: $TAG"
docker run --rm --privileged tonistiigi/binfmt:latest
docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --platform=linux/arm64,linux/amd64 --name multi-platform-builder
docker buildx inspect --bootstrap
docker buildx build --no-cache --platform=linux/arm64,linux/amd64 --push \
    --tag $REGISTRY/$IMG_NAME:$TAG \
    -f ./Dockerfile .
