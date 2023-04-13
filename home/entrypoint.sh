#!/usr/bin/env bash
## Entrypoint Script

set -E

###############################################################################
# Environment
###############################################################################

## Configure our default files.
export HOSTFILE="$DATA/.hostname"
export ARGSFILE="$DATA/.args"
export WORKPATH="$HOME/home"

## Ensure our environment is properly initialized.
! test -d "$DATA"     && mkdir -p $DATA
! test -d "$CONF"     && mkdir -p $CONF
! test -d "$LOGS"     && mkdir -p $LOGS
! test -f "$HOSTFILE" && touch $HOSTFILE
! test -f "$ARGSFILE" && touch $ARGSFILE

## Configure start command and arguments.
ARGS="$@"
[ -z "$CMD" ]  && CMD="tail"
[ -z "$ARGS" ] && ARGS="-f /dev/null"

###############################################################################
# Methods
###############################################################################

init() {
  ## Execute startup scripts.
  for script in `find /root/home/start -name *.*.sh | sort`; do
    echo "Executing script ${script}..."
    $script; state="$?"
    [ $state -ne 0 ] && exit $state
  done
}

###############################################################################
# Main
###############################################################################

## Ensure all files are executable.
for FILE in $PWD/bin/*   ; do chmod a+x $FILE; done
for FILE in $PWD/start/* ; do chmod a+x $FILE; done

## Check if binary exists.
[ -z "$(which $CMD)" ] && (echo "$CMD file is missing!" && exit 1)

## Load .bashrc
source /root/.bashrc

## Run init scripts.
init

## If hostname is not set, use container address as default.
[ ! -f "$HOSTFILE" ] && printf "https://$(hostname -I | tr -d ' ')" > "$HOSTFILE"

## Make sure argument file history is empty.
printf "" > $ARGSFILE

## Print our params string.
echo "Executing $CMD with arguments:"
for line in $ARGS; do echo $line | tee $ARGSFILE; done && echo

$CMD $ARGS