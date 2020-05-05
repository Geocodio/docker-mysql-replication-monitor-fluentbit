#!/bin/bash

while true; do
  /monitor.sh || true
  sleep $TIME_BETWEEN_CHECKS
done
