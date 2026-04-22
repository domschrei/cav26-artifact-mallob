#!/bin/bash

source scripts/setup-for-runs.sh

# Same parameters for all smoke test runs
export NPROCS=2
export NTHREADS=4
export TIMELIM=10

banner_run_suite "1/8 - SAT Solving, mixed portfolio"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/1-sat-mixed/ \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=kcl

banner_run_suite "2/8 - SAT Solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/2-sat-monolproof/ \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "3/8 - SAT Solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/3-sat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "4/8 - SAT Solving, streamlined preprocessing"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/4-sat-streamlined/ \
scripts/run-benchmark.sh -mono-app=SATWITHPRE -pl=1

banner_run_suite "5/8 - Incremental SAT Solving"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/5-incsat/ \
scripts/run-benchmark.sh -mono-app=INCSAT

banner_run_suite "6/8 - Incremental SAT Solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/6-incsat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=INCSAT -otfc=1 -otfci=1

banner_run_suite "7/8 - MaxSAT Solving"
BENCHMARKFILE=scripts/selection-maxsat-smoke.txt BASEDIR=$basedir/7-maxsat/ \
scripts/run-benchmark.sh -mono-app=MAXSAT -maxsat-searchers=1

banner_run_suite "8/8 - SMT Solving"
BENCHMARKFILE=scripts/selection-smt-smoke.txt BASEDIR=$basedir/8-smt/ \
scripts/run-benchmark.sh -mono-app=SMT

# TODO SCHEDULING VIA LIST

# TODO SCHEDULING ON DEMAND??

banner_run_done
