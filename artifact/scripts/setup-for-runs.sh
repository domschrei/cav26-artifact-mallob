#!/bin/bash

set -e

# Logging + results output
basedir="$(pwd)/share/mallob-$(hostname)-$(date +%s)"
mkdir -p "$basedir"

# Branch off all subsequent output to a log file in the output directory
exec > >(tee -a "$basedir/log.txt")


if ! [ -d /app/artifact/ ]; then       
       echo gcc
       spack load gcc@14.2.0%gcc@11.4.1 arch=linux-rocky9-x86_64
       echo openmpi
       spack load openmpi@5.0.5 arch=linux-rocky9-x86_64
       echo jemalloc
       spack load jemalloc@5.3.0%gcc@14.2.0 arch=linux-rocky9-x86_64
       echo gdb
       spack load gdb@14.2%gcc@14.2.0 arch=linux-rocky9-x86_64
fi


suite_idx=0 # counter for different suites

function banner_run_suite() {
    suite_idx=$(($suite_idx + 1))
    echo
    echo "####################################################################################"
    echo "RUNNING SUITE $suite_idx/$suite_count - $@"
    echo "####################################################################################"
    echo
}

function banner_run_done() {
    echo
    echo "####################################################################################"
    echo "All runs done. Find output at $basedir"
    echo "####################################################################################"
    echo
}
