#!/bin/bash

HEADERS="$(mktemp)"

EVENT_DATA=$(curl -sS -LD "$HEADERS" -X GET "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")

echo $EVENT_DATA

REQUEST_ID=$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)

echo $REQUEST_ID

tsung -f /.tsung/tsung.xml start

echo "Tsung finished"

cd /tmp/.tsung/log/$(ls -t /tmp/.tsung/log | head -n 1) && \
  /usr/lib/x86_64-linux-gnu/tsung/bin/tsung_stats.pl

echo "Report created"

aws s3 cp /tmp/.tsung/log s3://${S3_BUCKET}/tsung_results --recursive

echo "Complete uploading to S3"

RESPONSE="Finished"

curl -X POST "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response"  -d "$RESPONSE"
