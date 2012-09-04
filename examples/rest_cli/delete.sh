#!/bin/bash

if [ -z $1 ]; then
  echo "USAGE: delete.sh <metric_id>"
else
  curl -X DELETE "http://127.0.0.1:8889/v1/metrics/${1}"
fi
