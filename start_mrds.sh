#!/bin/bash

set -e 
set -o pipefail

source ./.env
source ./custom.env

file="docker-compose.yml"

if [ -f "$CUSTOM_DOCKER_COMPOSE_FILE" ]; then
    echo "Custom docker-compose file ${CUSTOM_DOCKER_COMPOSE_FILE} exists. Starting it now."
    file=${CUSTOM_DOCKER_COMPOSE_FILE}
else 
    echo "NO custom docker-compose file exists. Starting the default '${file}' now."
fi

## Download the newest image(s):
docker-compose -f ${file} pull

## Build the local image including the xserver stuff:
IMAGE_NAME=mrds_final_j
printf "\n\n##################################\n"
printf "$IMAGE_NAME"
printf "\n##################################\n"
printf "\nPulling cached $IMAGE_NAME image\n"
# build new image (latest):
printf "\n\nBuilding image $IMAGE_NAME:${VERSION_TAG}\n"

docker build \
    --progress=plain \
    --no-cache=true \
    --label "org.label-schema.name=mikeintosh/$IMAGE_NAME" \
    --label "org.label-schema.vsc-url=https://github.com/MIKEINTOSHSYSTEMS/MIKEINTOSH_RDataSystems/blob/main/Dockerfiles/$IMAGE_NAME.dockerfile" \
    --label "org.label-schema.vcs-ref=$(git rev-parse HEAD)" \
    --label "org.label-schema.version=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg VERSION_TAG=${VERSION_TAG} \
    --build-arg DISPLAY=${DISPLAY} \
    -f ./Dockerfiles/$IMAGE_NAME.dockerfile \
    -t $REGISTRY_PREFIX/mrds_rstudio_j:$VERSION_TAG . 2>&1 | tee ./log_$IMAGE_NAME.log

## Spin them up:
docker-compose -f ${file} up -d
