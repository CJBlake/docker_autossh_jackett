#!/bin/bash\
base_name="$(basename "$0")"
lock_file="/tmp/$base_name.lock"
trap "rm -f $lock_file exit 0" SIGINT SIGTERM
if [ -e "$lock_file" ]
then
    echo "$base_name is running already."
    exit
else
    touch "$lock_file"
    autossh -M ${MONITOR_PORT_1} -f -NR 0.0.0.0:${JACKETT_PORT}_PORT}:localhost:${LOCAL_PORT} ${JACKETT_USER}@${JACKETT_HOST} -C
    autossh -M ${MONITOR_PORT_2} -f -NR 0.0.0.0:${FERAL_PORT}_PORT}:localhost:${LOCAL_PORT} ${FERAL_USER}@${FERAL_HOST} -C
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
