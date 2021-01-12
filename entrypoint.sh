#!/bin/sh
env 
echo "starting the This Week In view..."
JSON_STRING=' window.configs = { "VUE_APP_SERVICE_ROOT": "'"${VUE_APP_SERVICE_ROOT}"'" }'
INDEX_FILE=/usr/share/nginx/html/index.html
FIXED_HTML=$(  sed "s@// CONFIGURATIONS_PLACEHOLDER@${JSON_STRING}@" $INDEX_FILE )
echo $FIXED_HTML > $INDEX_FILE
cat /usr/share/nginx/html/index.html
exec "$@"
