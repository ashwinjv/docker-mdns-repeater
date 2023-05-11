#!/bin/bash

# Exit on error
set -e

# Load functions
source /scripts/update-app-user-uid-gid.sh

# Debug output
set -x

update_user_gid $APP_USERNAME $APP_GROUPNAME $APP_GID
update_user_uid $APP_USERNAME $APP_UID

if [ "$1" = $APP_NAME ]; then
  shift;
  if ! [ -z "$REPEATER_DOCKER_NETWORK" ]; then
    HOST_IFACE=`route | grep '^default' | grep -o '[^ ]*$'`
    REPEATER_IFACE="br-`docker inspect $REPEATER_DOCKER_NETWORK | jq -r '.[0].Id[0:12]'`"
    MDNS_REPEATER_INTERFACES="$HOST_IFACE $REPEATER_IFACE"
    exec /scripts/app-entrypoint.sh $APP_BIN -f $MDNS_REPEATER_INTERFACES "$@"
  else
    exec /scripts/app-entrypoint.sh $APP_BIN "$@"
  fi
fi

exec "$@"
