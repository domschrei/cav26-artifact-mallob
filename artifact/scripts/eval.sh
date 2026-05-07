#!/bin/bash

if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi

if [ -z $1 ]; then echo "Error: Provide a directory to evaluate" ; exit 1 ; fi
dir="$1"

scripts/eval-benchmark.sh "$dir"
scripts/plot-benchmark.sh "$dir"
