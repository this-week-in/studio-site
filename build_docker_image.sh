#!/bin/bash

ROOT=$( cd $(dirname $0)  && pwd )
cd $ROOT
docker build -t twi-editor-view .
