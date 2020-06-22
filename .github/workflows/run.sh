#!/usr/bin/env bash 

cd $GITHUB_WORKSPACE 
npm install
npm run build
./deploy/cf.sh
./deploy/deploy.sh

