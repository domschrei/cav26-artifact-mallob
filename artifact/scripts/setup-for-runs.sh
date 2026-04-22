#!/bin/bash

set -e

# Logging + results output
basedir="$(pwd)/share/mallob-$(hostname)-$(date +%s)"
mkdir -p "$basedir"

# Branch off all subsequent output to a log file in the output directory
exec > >(tee -a "$basedir/log.txt")


function banner_run_suite() {
    echo
    echo "************************************************************"
    echo "RUNNING SUITE $@"
    echo "************************************************************"
    echo
}

function banner_run_done() {
    echo
    echo "************************************************************"
    echo "All runs done. Find output at $basedir"
    echo "************************************************************"
    echo
}
