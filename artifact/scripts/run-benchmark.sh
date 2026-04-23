#!/bin/bash

if [ -z $NPROCS ]; then echo "Error: \$NPROCS not provided" ; exit 1 ; fi
if [ -z $NTHREADS ]; then echo "Error: \$NTHREADS not provided" ; exit 1 ; fi
if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi

basedir="$(pwd)/share/mallob-$(hostname)-$(date +%s)"
if ! [ -z $BASEDIR ]; then basedir="$BASEDIR" ; fi

benchmarkfile="../benchmark-commands.txt"
if ! [ -z $BENCHMARKFILE ]; then benchmarkfile="$BENCHMARKFILE" ; fi


mkdir -p $basedir
echo "Base output directory: $basedir"
echo

if ! [ -z $NUM_PARTITIONS ]; then
    if [ -z $PARTITION_INDEX ]; then echo "Error: \$PARTITION_INDEX not provided" ; exit 1 ; fi
    cat "$benchmarkfile" | awk 'NR % '$NUM_PARTITIONS' == '$PARTITION_INDEX > .commands.txt
else
    cp "$benchmarkfile" .commands.txt
fi

cat .commands.txt | sort -k 1,1b > $basedir/commands.txt

ninputs=$(cat .commands.txt|wc -l)
for id in $(seq 1 $ninputs); do
    input=$(sed $id'q;d' .commands.txt|awk '{print $NF}')

    mkdir $basedir/$id

    echo "$(date) BEGIN $id/$ninputs $input"
    LOGDIR="$(cd $basedir/$id && pwd)" scripts/run-single.sh "$input" $@
    echo "$(date) END $id/$ninputs $input"
    echo
done
