#!/usr/bin/env bash 

cd $CHECKOUT_DIR
echo "inside ${CHECKOUT_DIR}"
pwd 
echo "========="
npm install
npm run build
./deploy/cf.sh
./deploy/deploy.sh

