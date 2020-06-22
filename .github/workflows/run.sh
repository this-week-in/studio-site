#!/usr/bin/env bash 

cd $CHECKOUT_DIR
echo "inside ${CHECKOUT_DIR}"
pwd 
echo "========="
npm install
npm run build
echo "inside the directory ..."
pwd 
ls -la 
./deploy/cf.sh

./deploy/deploy.sh

