#!/bin/bash\

groupadd -g "${PGID}" "${AUTOSSH_GROUP}"
useradd -u "${PUID}" -g "${AUTOSSH_GROUP}" -d "/config/${AUTOSSH_USER}" "${AUTOSSH_USER}"
echo "${AUTOSSH_USER}":"${USER_PASSWORD}" | chpasswd
su "${AUTOSSH_USER}" -c "mkdir /config/scripts"
su "${AUTOSSH_USER}" -c "cat > /config/scripts/portforward.sh << 'ENDMASTER'
$(
###### No parameter substitution
cat <<'INNERMASTER'
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
    autossh -M ${MONITOR_PORT_2} -f -NR 0.0.0.0:${FERAL_PORT}_PORT}:localhost:${LOCAL_PORT} ${FERAL_USERNAME}@${FERAL_HOST} -C
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
fi
INNERMASTER
)
ENDMASTER"
su "${AUTOSSH_USER}" -c "chmod 770 /config/scripts/portforward.sh" # Make the script executable
su "${AUTOSSH_USER}" -c "bash /config/scripts/portforward.sh" # Run the script

