#!/bin/bash
set -e
set -o pipefail

TAG_NAME=${1:-$(date +%s)}
ROOT=$( cd $(dirname $0)  && pwd )

cd $ROOT

docker build -t twi-editor-view .
git tag $TAG_NAME
git push origin $TAG_NAME

