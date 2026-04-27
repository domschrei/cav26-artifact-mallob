#!/bin/bash

source scripts/setup-for-runs.sh

suite_count=16 # number of experiments


# Single-core baselines

banner_run_suite "[1x] SAT solving, mixed portfolio"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-mixed/ \
NPROCS=1 NTHREADS=1 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=kcl

banner_run_suite "[1x] SAT solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-monolproof/ \
NPROCS=1 NTHREADS=1 TIMELIM=60 \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "[1x] SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-rtcheck/ \
NPROCS=1 NTHREADS=1 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "[1x] SAT solving, streamlined preprocessing"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-streamlined/ \
NPROCS=1 NTHREADS=1 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SATWITHPRE -pl=1

banner_run_suite "[1x] Incremental SAT solving"
BENCHMARKFILE=scripts/selection-incsat-demo-small.txt BASEDIR=$basedir/$suite_idx-incsat/ \
NPROCS=1 NTHREADS=1 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=INCSAT

banner_run_suite "[1x] Incremental SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-incsat-demo-small.txt BASEDIR=$basedir/$suite_idx-incsat-rtcheck/ \
NPROCS=1 NTHREADS=12 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=INCSAT -otfc=1 -otfci=1

banner_run_suite "[1x] MaxSAT solving"
BENCHMARKFILE=scripts/selection-maxsat-demo-small.txt BASEDIR=$basedir/$suite_idx-maxsat/ \
NPROCS=1 NTHREADS=1 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=MAXSAT -maxsat-searchers=1

banner_run_suite "[1x] SMT solving"
BENCHMARKFILE=scripts/selection-smt-demo-small.txt BASEDIR=$basedir/$suite_idx-smt/ \
NPROCS=1 NTHREADS=1 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SMT


# 32-core runs

banner_run_suite "[12x] SAT solving, mixed portfolio"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-mixed/ \
NPROCS=1 NTHREADS=12 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=kcl

banner_run_suite "[12x] SAT solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-monolproof/ \
NPROCS=1 NTHREADS=12 TIMELIM=60 \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "[12x] SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-rtcheck/ \
NPROCS=1 NTHREADS=12 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "[12x] SAT solving, streamlined preprocessing"
BENCHMARKFILE=scripts/selection-sat-demo-small.txt BASEDIR=$basedir/$suite_idx-sat-streamlined/ \
NPROCS=3 NTHREADS=4 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SATWITHPRE -pl=1

banner_run_suite "[12x] Incremental SAT solving"
BENCHMARKFILE=scripts/selection-incsat-demo-small.txt BASEDIR=$basedir/$suite_idx-incsat/ \
NPROCS=1 NTHREADS=12 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=INCSAT

banner_run_suite "[12x] Incremental SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-incsat-demo-small.txt BASEDIR=$basedir/$suite_idx-incsat-rtcheck/ \
NPROCS=1 NTHREADS=12 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=INCSAT -otfc=1 -otfci=1

banner_run_suite "[12x] MaxSAT solving"
BENCHMARKFILE=scripts/selection-maxsat-demo-small.txt BASEDIR=$basedir/$suite_idx-maxsat/ \
NPROCS=4 NTHREADS=3 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=MAXSAT -maxsat-searchers=4 -maxsat-focus-period=15 -cjc=1

banner_run_suite "[12x] SMT solving"
BENCHMARKFILE=scripts/selection-smt-demo-small.txt BASEDIR=$basedir/$suite_idx-smt/ \
NPROCS=4 NTHREADS=3 TIMELIM=60 \
scripts/run-benchmark.sh -mono-app=SMT


# Some scaling for scheduling experiments

for p in 4 8 ; do
    banner_run_suite "[${p}x] Scheduling"
    NPROCS=$p NTHREADS=1 TIMELIM=1800 \
    BENCHMARKFILE=scripts/selection-none.txt BASEDIR=$basedir/$suite_idx-scheduling/ \
    MPIPARAMS="--oversubscribe" \
    scripts/run-benchmark.sh -mono-app=SAT -job-desc-template=$(pwd)/scripts/selection-sat-demo-small.txt \
    -job-template=templates/tj.json -client-template=templates/tc.json -c=1 \
    -J=$(cat $(pwd)/scripts/selection-sat-demo-small.txt | wc -l) -ajpc=4 -jwl=60
done


banner_run_done
