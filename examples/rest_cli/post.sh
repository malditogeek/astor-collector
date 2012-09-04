#!/bin/bash

if [ -z $1 ] || [ -z $2 ]; then
  echo "USAGE: post.sh <metric_id> <value>"
else
  curl -v -X POST "http://127.0.0.1:8889/v1/metrics/${1}?value=${2}"
fi
