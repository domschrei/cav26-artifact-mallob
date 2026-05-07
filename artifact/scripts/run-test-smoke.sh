#!/bin/bash

source scripts/setup-for-runs.sh

# Parameters across all smoke test runs
export TIMELIM=5

suite_count=17 # number of experiments/suites


# Pseudo sequential setup (baseline for basic speedups)

export NPROCS=1
export NTHREADS=1
scale=$(($NPROCS * $NTHREADS))

banner_run_suite "[${scale}x] SAT solving, mixed portfolio"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-mixed/ \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=kcl

banner_run_suite "[${scale}x] SAT solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-monolproof/ \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "[${scale}x] SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "[${scale}x] SAT solving, streamlined preprocessing"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-streamlined/ \
NPROCS=2 scripts/run-benchmark.sh -mono-app=SATWITHPRE -pl=1

banner_run_suite "[${scale}x] Incremental SAT solving"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-incsat/ \
scripts/run-benchmark.sh -mono-app=INCSAT

banner_run_suite "[${scale}x] Incremental SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-incsat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=INCSAT -otfc=1 -otfci=1

banner_run_suite "[${scale}x] MaxSAT solving"
BENCHMARKFILE=scripts/selection-maxsat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-maxsat/ \
scripts/run-benchmark.sh -mono-app=MAXSAT -maxsat-searchers=1

banner_run_suite "[${scale}x] SMT solving"
BENCHMARKFILE=scripts/selection-smt-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-smt/ \
NPROCS=2 scripts/run-benchmark.sh -mono-app=SMT -md=1


# Parallel setup (2x4 threads)

export NPROCS=2
export NTHREADS=4
scale=$(($NPROCS * $NTHREADS))

banner_run_suite "[${scale}x] SAT solving, mixed portfolio"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-mixed/ \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=kcl

banner_run_suite "[${scale}x] SAT solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-monolproof/ \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "[${scale}x] SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "[${scale}x] SAT solving, streamlined preprocessing"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-streamlined/ \
scripts/run-benchmark.sh -mono-app=SATWITHPRE -pl=1

banner_run_suite "[${scale}x] Incremental SAT solving"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-incsat/ \
scripts/run-benchmark.sh -mono-app=INCSAT

banner_run_suite "[${scale}x] Incremental SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-incsat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=INCSAT -otfc=1 -otfci=1

banner_run_suite "[${scale}x] MaxSAT solving"
BENCHMARKFILE=scripts/selection-maxsat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-maxsat/ \
scripts/run-benchmark.sh -mono-app=MAXSAT -maxsat-searchers=1

banner_run_suite "[${scale}x] SMT solving"
BENCHMARKFILE=scripts/selection-smt-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-smt/ \
scripts/run-benchmark.sh -mono-app=SMT


# Scheduling experiment

banner_run_suite "Scheduling"
NPROCS=32 NTHREADS=1 TIMELIM=120 \
BENCHMARKFILE=scripts/selection-none.txt BASEDIR=$basedir/$suite_idx-c$(($NPROCS * $NTHREADS))-scheduling/ \
MPIPARAMS="--oversubscribe" \
scripts/run-benchmark.sh -mono-app=SAT -job-desc-template=$(pwd)/scripts/selection-sat-smoke.txt \
-job-template=templates/tj.json -client-template=templates/tc.json -c=1 \
-J=$(cat $(pwd)/scripts/selection-sat-smoke.txt | wc -l) -ajpc=5 -jwl=60


banner_run_done
