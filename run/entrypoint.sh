#!/usr/bin/env bash
## Entrypoint script for image.

set -E

###############################################################################
# Environment
###############################################################################

IND=`fgc 215 "|-"`
SCRIPT_PATH="$RUNPATH/scripts"

###############################################################################
# Methods
###############################################################################

run_scripts() {
  [ -z "$1" ] && exit 1
  EXECPATH="$SCRIPT_PATH/$1"
  if [ -d "$EXECPATH" ]; then
    run_script_dir "$EXECPATH"
  else
    EXECPATH=`find $SCRIPT_PATH -maxdepth 1 -name $1.*`
    [ -f "$EXECPATH" ] \
      && run_script_file "$EXECPATH"
  fi
}

run_script_file() {
  printf "Executing '$1' ...\n"
  chmod +x $1
  IND=$IND $1; state="$?"
  if [ $state -ne 0 ]; then exit $state; fi
}

run_script_dir() {
  for script in `find $1 -name *.* | sort`; do
    chmod +x $script
    IND=$IND $script; state="$?"
    if [ $state -ne 0 ]; then exit $state; fi
  done
}

clean_exit() {
  ## If exit code is non-zero, print fail message and clean up.
  status="$?"
  [ $status -gt 1 ] && ( printf "\nFailed with exit code $status"; templ fail )
  [ $status -gt 1 ] && [ -z "$DEVMODE" ] && cleanup $status || exit 0
}

cleanup() {
  ## Delete share info before exiting.
  if [ -z "$DEVMODE" ]; then
    printf "Delisting $SHAREPATH/$HOSTNAME ... "
    rm -rf "$SHAREPATH/$HOSTNAME"
    printf "done.\n" && exit $1
  fi
}

###############################################################################
# Script
###############################################################################

trap clean_exit EXIT; trap cleanup SIGTERM SIGKILL

## Add some delay for docker to attach tty properly.
[ -z "$DEVMODE" ] && sleep 1

## Make sure we are in root.
cd /root

## Run scripts, else launch terminal.
[ -n "$1" ] && run_scripts $1 || terminal
exit 0
