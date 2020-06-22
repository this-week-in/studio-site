#!/usr/bin/env bash
START_DIR=$(cd `dirname $0` && pwd )
source "$START_DIR/env.sh"
# ROOT=${GITHUB_WORKSPACE:-$(cd ${START_DIR}/../ && pwd )}
# cd $ROOT
cd $CHECKOUT_DIR

ls -la dist || echo "no dist directory to be found"
cp ${CHECKOUT_DIR}/deploy/manifest.yml dist
cp ${CHECKOUT_DIR}/deploy/Staticfile dist
cd dist
cf push -f manifest.yml