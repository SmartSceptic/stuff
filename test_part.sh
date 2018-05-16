#!/bin/bash

# variables
LOGFILE="/bin/vlad/access.log"
LOGFILE_GZ="/var/log/nginx/access.log.*"
RESPONSE_CODE="200"
Field=" Field"
n="1"
request_ips(){
for (( i = 0; i < 29; i++ ))
do
eval " tail -1 $LOGFILE | awk '{print \"Field $i\" \" =      \" \$$i}'"
done
}

request_ips
