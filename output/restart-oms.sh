#!/bin/bash

PID=$(pgrep -f bin/oms)
echo "Restarting PID="$PID
kill -HUP $PID