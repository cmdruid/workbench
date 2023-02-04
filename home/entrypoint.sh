#!/usr/bin/env sh
## Entrypoint Script

set -E

###############################################################################
# Environment
###############################################################################

CMD="bash"
DEFAULT_REMOTE_PORT=8080

export HOSTFILE="$DATA/.hostname"
export PARAM_FILE="$DATA/.params"

###############################################################################
# Methods
###############################################################################

init() {
  ## Execute startup scripts.
  for script in `find /root/home/start -name *.*.sh | sort`; do
    $script; state="$?"
    [ $state -ne 0 ] && exit $state
  done
}

###############################################################################
# Main
###############################################################################

## Set defaults.
[ -z "$REMOTE_PORT" ] && REMOTE_PORT=$DEFAULT_REMOTE_PORT

## Ensure all files are executable.
for FILE in $PWD/bin/*   ; do chmod a+x $FILE; done
for FILE in $PWD/start/* ; do chmod a+x $FILE; done

## Check if binary exists.
[ -z "$(which $CMD)" ] && (echo "$CMD file is missing!" && exit 1)

## Make sure temp files is empty.
printf "" > $PARAM_FILE

## Run init scripts.
init

## If hostname is not set, use container address as default.
[ ! -f "$HOSTFILE" ] && printf "https://$(hostname -I | tr -d ' '):$REMOTE_PORT" > "$HOSTFILE"

## Construct final params string.
PARAMS="$@"

## Print our params string.
echo "Executing $CMD with params:"
for line in $PARAMS; do echo $line; done && echo

$CMD