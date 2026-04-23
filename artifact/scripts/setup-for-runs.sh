#!/bin/bash

set -e

# Logging + results output
basedir="$(pwd)/share/mallob-$(hostname)-$(date +%s)"
mkdir -p "$basedir"

# Branch off all subsequent output to a log file in the output directory
exec > >(tee -a "$basedir/log.txt")


suite_idx=0 # counter for different suites

function banner_run_suite() {
    suite_idx=$(($suite_idx + 1))
    echo
    echo "************************************************************"
    echo "RUNNING SUITE $suite_idx/$suite_count - $@"
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
