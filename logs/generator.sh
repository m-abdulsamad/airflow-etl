#!/bin/sh

# generate logs in the background
/home/abdulsamad/Documents/repos/sql-etl/env/bin/log-generator /home/abdulsamad/Documents/repos/sql-etl/logs/config.yml &

# get the process id of the background running process
PID=$!
# Wait for 60 seconds
sleep 60
# Kill it
kill $PID;


