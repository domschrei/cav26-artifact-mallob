#!/bin/bash

source scripts/setup-for-runs.sh

# Parameters across all smoke test runs
export TIMELIM=5

suite_count=8 # number of experiments/suites


# Pseudo sequential setup (baseline for basic speedups)

export NPROCS=1
export NTHREADS=1
scale=$(($NPROCS * $NTHREADS))

banner_run_suite "[${scale}x] SAT solving, unchecked"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-unchecked/ \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=c

banner_run_suite "[${scale}x] SAT solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-monolproof/ \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "[${scale}x] SAT solving, fast real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "[${scale}x] SAT solving, proof checking with ImpCake"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-impcake/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=0 -otfcm=0


# Parallel setup (8 threads)

export NPROCS=1
export NTHREADS=8
scale=$(($NPROCS * $NTHREADS))

banner_run_suite "[${scale}x] SAT solving, unchecked"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-unchecked/ \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=c

banner_run_suite "[${scale}x] SAT solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-monolproof/ \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "[${scale}x] SAT solving, fast real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "[${scale}x] SAT solving, proof checking with ImpCake"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-c$scale-sat-impcake/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=0 -otfcm=0


banner_run_done
