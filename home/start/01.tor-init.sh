#!/bin/sh
## Startup script for tor.

set -E

###############################################################################
# Environment
###############################################################################

CONF_FILE="$CONF/torrc"
LOGS_PATH="/var/log/tor"
COOK_PATH="/var/lib/tor"

###############################################################################
# Script
###############################################################################

if [ "$TOR_ENABLED" = 1 ]; then

  echo "Initializing Tor"

  ## Create missing paths.
  [ ! -d "$LOGS_PATH" ] && mkdir -p -m 700 $LOGS_PATH
  [ ! -d "$COOK_PATH" ] && mkdir -p -m 700 $COOK_PATH

  ## Start tor then tail the logfile to search for the completion phrase.
  tmux new -d -s tor "tor -f $CONF_FILE" && sleep 1
  tail -f $LOGS_PATH/notice.log | while read line; do
    echo "$line" && echo "$line" | grep "Bootstrapped 100%" > /dev/null 2>&1
    if [ $? = 0 ]; then 
      echo "Tor initialized!" && exit 0
    fi
  done

  ## Add proxy command to cln config string.
  ## ARGS_STR="$ARGS_STR --proxy=127.0.0.1:9050"

  ## Add hostname
  ## printf "http://$(cat $DATA/hidden/hostname):$SPARK_PORT" > "$SPARK_HOST"

fi
