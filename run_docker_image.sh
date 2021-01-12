#!/bin/bash

ROOT=$( cd $(dirname $0)/.. && pwd )
ENV_FILE=$ROOT/.env.production
docker run -it -p 8080:80 -e VUE_APP_SERVICE_ROOT='http://some-k8s-pod.com'  --rm twi-editor-view
