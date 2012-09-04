#!/bin/bash

if [ -z $1 ]; then
  echo "USAGE: get.sh <metric_id>"
else
  curl -v -X GET "http://127.0.0.1:8889/v1/metrics/${1}"
fi
