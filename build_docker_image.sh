#!/bin/bash
set -e
set -o pipefail
##
##
APP_NAME=twi-editor-view
PROJECT_ID=${GCLOUD_PROJECT}
TAG_NAME=${1:-$(date +%s)}
IMAGE_TAG="production${GITHUB_SHA:-}"
GCR_IMAGE_NAME=gcr.io/${PROJECT_ID}/${APP_NAME}
IMAGE_NAME=${GCR_IMAGE_NAME}:${IMAGE_TAG}
##
##
cd $( cd $(dirname $0)  && pwd )
docker build -t $APP_NAME .
image_id=$(docker images -q $APP_NAME)
docker tag "${image_id}" ${IMAGE_NAME}:latest
docker tag "${image_id}" $IMAGE_NAME
docker push $IMAGE_NAME


echo "pushing ${image_id} to $IMAGE_NAME "
echo "tagging ${GCR_IMAGE_NAME}"

