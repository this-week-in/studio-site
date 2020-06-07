#!/usr/bin/env bash
START_DIR=$(cd `dirname $0` && pwd )
source "$START_DIR/env.sh"
ROOT=${GITHUB_WORKSPACE:-$(cd ${START_DIR}/../ && pwd )}
cd $ROOT
ls -la dist || echo "no dist directory to be found"
cp $ROOT/deploy/manifest.yml dist
cp $ROOT/deploy/Staticfile dist
cd dist
cf push -f manifest.yml