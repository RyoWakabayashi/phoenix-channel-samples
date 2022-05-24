#!/bin/bash

tsung -f tsung.xml start

echo "Finished Tsung"

cd /root/.tsung/log/$(ls -t /root/.tsung/log | head -n 1) && \
  /usr/lib/x86_64-linux-gnu/tsung/bin/tsung_stats.pl
