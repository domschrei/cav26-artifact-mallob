#!/bin/bash

if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi

basedir="$1"
if [ -z "$basedir" ]; then echo "Error: 1st argument <base-dir> not provided" ; exit 1 ; fi

for d in $basedir/*/ ; do
    scripts/eval-single.sh $d
    echo "$(basename $d) : $(cat $d/qresults.txt | awk '$2 != "UNKNOWN" && $2 != "ERROR"' | wc -l)/$(cat $d/commands.txt | wc -l) solved"
done
