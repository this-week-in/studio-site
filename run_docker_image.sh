#!/bin/bash

ROOT=$( cd $(dirname $0)/.. && pwd )
echo $ROOT
#ls -la
ENV_FILE=$ROOT/.env.production
#echo "VUE_APP_SERVICE_ROOT=https://ttd-editor-api.cfapps.io" > $ENV_FILE
#docker run -it -p 8080:80 --env-file=$ENV_FILE --rm twi-editor-view
docker run -it -p 8080:80 -e VUE_APP_SERVICE_ROOT='http://some-k8s-pod.com'  --rm twi-editor-view
