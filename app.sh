#!/bin/ash

SSH_OPTIONS=""

[ -z "$PLUGIN_HOST" ] && echo "'host' is not set" && exit 1
[ ! -z "$PLUGIN_PORT" ] && SSH_OPTIONS="$SSH_OPTIONS -p $PLUGIN_PORT"
if [ -z "$PLUGIN_HOST_FINGERPRINT" ]; then
    echo "StrictHostKeyChecking is disabled"
    SSH_OPTIONS="$SSH_OPTIONS -o StrictHostKeyChecking=no"
else
    echo "StrictHostKeyChecking is enabled"
    SSH_OPTIONS="$SSH_OPTIONS -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/tmp/known_hosts"

    echo "$PLUGIN_HOST_FINGERPRINT" | base64 -d > /tmp/known_hosts 2>/dev/null
    if [ $? != 0 ]; then
        echo "$PLUGIN_HOST $PLUGIN_HOST_FINGERPRINT" > /tmp/known_hosts
    fi
fi

[ -z "$PLUGIN_USER" ] && echo "'user' is not set" && exit 1
[ -z "$PLUGIN_KEY" ] && echo "'key' is not set" && exit 1
[ -z "$PLUGIN_SOURCE" ] && echo "'source' is not set" && exit 1
PLUGIN_SOURCE=$(echo $PLUGIN_SOURCE | tr , ' ')
[ -z "$PLUGIN_DESTINATION" ] && echo "'destination' is not set" && exit 1
[ -z "$PLUGIN_RETRIES" ] && PLUGIN_RETRIES=3
[ -z "$PLUGIN_RETRY_INTERVAL" ] && PLUGIN_RETRY_INTERVAL=5

umask 177
echo "$PLUGIN_KEY" | base64 -d > /tmp/ssh-id 2>/dev/null
if [ $? != 0 ]; then
    echo "$PLUGIN_KEY" > /tmp/ssh-id
fi

RSYNC_OPTIONS=""
[ ! -z "$PLUGIN_DELETE" ] && RSYNC_OPTIONS="$RSYNC_OPTIONS --delete"
[ ! -z "$PLUGIN_EXTRA" ] && RSYNC_OPTIONS="$RSYNC_OPTIONS $PLUGIN_EXTRA"

for i in $(seq 1 $PLUGIN_RETRIES); do
    echo rsync -az -e "ssh -i /tmp/ssh-id -l $PLUGIN_USER $SSH_OPTIONS" $RSYNC_OPTIONS $PLUGIN_SOURCE $PLUGIN_HOST:$PLUGIN_DESTINATION
    rsync -az -e "ssh -i /tmp/ssh-id -l $PLUGIN_USER $SSH_OPTIONS" $RSYNC_OPTIONS $PLUGIN_SOURCE $PLUGIN_HOST:$PLUGIN_DESTINATION && exit 0
    echo "rsync failed, retrying in $PLUGIN_RETRY_INTERVAL seconds"
    sleep $PLUGIN_RETRY_INTERVAL
done
echo "rsync failed after $PLUGIN_RETRIES retries"
exit 1
