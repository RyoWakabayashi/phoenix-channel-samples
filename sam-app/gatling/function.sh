#!/bin/bash

HEADERS="$(mktemp)"

EVENT_DATA=$(curl -sS -LD "$HEADERS" -X GET "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")

echo $EVENT_DATA

REQUEST_ID=$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)

echo $REQUEST_ID

sudo ulimit -n 64000

echo "ulimit values"

ulimit -n
ulimit -Sn
ulimit -Hn

cp -r ${GATLING_HOME} /tmp/gatling

export GATLING_HOME=/tmp/gatling

echo "Start Simulation"

/tmp/gatling/bin/gatling.sh -s WebSocketSimulation

echo "Complete Simulation"

aws s3 cp /tmp/gatling/results s3://${S3_BUCKET}/ws_results --recursive

echo "Complete uploading to S3"

RESPONSE="Finished"

curl -X POST "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response"  -d "$RESPONSE"
