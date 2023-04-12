#!/usr/bin/env sh
## Entrypoint Script

set -E

###############################################################################
# Environment
###############################################################################

CMD="bash"

export DATA="/data"
export ARGS="$@"
export HOSTFILE="$DATA/.hostname"
export ARGSFILE="$DATA/.args"

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