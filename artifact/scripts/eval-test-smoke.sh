#!/bin/bash

if [ -z $1 ]; then echo "Error: Provide a directory to evaluate" ; exit 1 ; fi
dir="$1"

TIMELIM=1 scripts/eval.sh "$dir"


