#!/usr/bin/env sh
## Ngrok init script.

set -E

###############################################################################
# Environment
###############################################################################

[ -z "$NGROK_TYPE" ]  && NGROK_TYPE  = 'http'
[ -z "$NGROK_PROTO" ] && NGROK_PROTO = 'http'
[ -z "$NGROK_HOST" ]  && NGROK_HOST  = '127.0.0.1'
[ -z "$NGROK_PORT" ]  && NGROK_PORT  = '80'

###############################################################################
# Main
###############################################################################

if [ -n "$NGROK_ENABLED" ] && [ -n "$NGROK_TOKEN" ]; then

  echo "Initializing Ngrok"

  FULL_URL="ngrok $NGROK_TYPE $NGROK_PROTO://$NGROK_HOST:$NGROK_PORT"

  ngrok config add-authtoken "$NGROK_TOKEN"
  tmux new -d -s ngrok "$FULL_URL" && sleep 2
  curl -s localhost:4040/api/tunnels | jq -r .tunnels[0].public_url > "$HOSTFILE"
fi
