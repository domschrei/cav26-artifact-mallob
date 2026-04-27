#!/bin/bash

if [ -z $NPROCS ]; then echo "Error: \$NPROCS not provided" ; exit 1 ; fi
if [ -z $NTHREADS ]; then echo "Error: \$NTHREADS not provided" ; exit 1 ; fi
if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi
if [ -z $LOGDIR ]; then echo "Error: \$LOGDIR not provided" ; exit 1 ; fi

export MALLOC_CONF="thp:always"
export OMPI_MCA_btl_vader_single_copy_mechanism=none
export RDMAV_FORK_SAFE=1

localtmpdir="/tmp"
globallogdir="$LOGDIR"

cd mallob

jobslots=$(($NPROCS / 2))
if [ $jobslots == 0 ]; then jobslots=1 ; fi

input="$1"
shift 1

if [ "$NO_DOCKER" = "1" ]; then
  echo "NO_DOCKER is set"
  input=$(echo "$input" | sed 's|^/app/||')
  echo "Stripped app, now: " $input
else
  echo "NO_DOCKER is not set"
fi

# decompress as needed
if echo "$input" | grep -qE '.xz$'; then
  input_dec=$(echo "$input" | sed 's/\.xz$//g')
  if ! [ -f "$input_dec" ]; then
    echo "Decompressing input $input -> $input_dec"
    xz -dk "$input"
  fi
  input="$input_dec"
  echo "Using decompressed input $input"
fi

cmd="mpirun --mca btl_tcp_if_include eth0 --allow-run-as-root -np $NPROCS --bind-to none $MPIPARAMS\
 build/mallob -mono=$input -jwl=$TIMELIM -T=$(($TIMELIM+10)) -wam=10``000 -pre-cleanup=1\
 -q=1 -log=$globallogdir -tmp=$localtmpdir -proof-dir=$localtmpdir/proof -sro=${globallogdir}/processed-jobs.out\
 -trace-dir=${globallogdir}/ -os=1 -v=4 -iff=0 -s2f=${globallogdir}/res.txt -smt-out-file=${globallogdir}/out.smt2\
 -rpa=1 -pph=$NPROCS -mlpt=20``000``000 -t=$NTHREADS -cm=1 -seed=0 -isp=1 -js=$jobslots -jc=2 -tst=1\
 -terminate-abruptly=1 $@"
if [ "x$MONOPROOF" == "x1" ]; then
  cmd="$cmd -proof=$globallogdir/proof.rlrup -uninvert-proof=0"
fi

echo "Executing: $cmd"

$cmd

# check monolithic proof as needed
if [ "x$MONOPROOF" == "x1" ] && [ -f $globallogdir/res.txt ] && grep -qE "^s UNSATISFIABLE$" $globallogdir/res.txt ; then
  build/standalone_lrat_checker $input $globallogdir/proof.rlrup --reversed > $globallogdir/chk.txt
fi
if [ -f $globallogdir/proof.rlrup ]; then
  rm $globallogdir/proof.rlrup
fi
