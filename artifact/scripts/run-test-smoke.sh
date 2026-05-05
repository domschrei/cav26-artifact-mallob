#!/bin/bash

source scripts/setup-for-runs.sh

# Same parameters for all smoke test runs
export NPROCS=2
export NTHREADS=4
export TIMELIM=1

suite_count=9 # number of experiments

banner_run_suite "SAT solving, mixed portfolio"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-sat-mixed/ \
scripts/run-benchmark.sh -mono-app=SAT -satsolver=kcl

banner_run_suite "SAT solving, monolithic proof production"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-sat-monolproof/ \
MONOPROOF=1 scripts/run-benchmark.sh -mono-app=SAT

banner_run_suite "SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-sat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=SAT -otfc=1 -otfci=1

banner_run_suite "SAT solving, streamlined preprocessing"
BENCHMARKFILE=scripts/selection-sat-smoke.txt BASEDIR=$basedir/$suite_idx-sat-streamlined/ \
scripts/run-benchmark.sh -mono-app=SATWITHPRE -pl=1

banner_run_suite "Incremental SAT solving"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/$suite_idx-incsat/ \
scripts/run-benchmark.sh -mono-app=INCSAT

banner_run_suite "Incremental SAT solving, real-time proof checking"
BENCHMARKFILE=scripts/selection-incsat-smoke.txt BASEDIR=$basedir/$suite_idx-incsat-rtcheck/ \
scripts/run-benchmark.sh -mono-app=INCSAT -otfc=1 -otfci=1

banner_run_suite "MaxSAT solving"
BENCHMARKFILE=scripts/selection-maxsat-smoke.txt BASEDIR=$basedir/$suite_idx-maxsat/ \
scripts/run-benchmark.sh -mono-app=MAXSAT -maxsat-searchers=1

banner_run_suite "SMT solving"
BENCHMARKFILE=scripts/selection-smt-smoke.txt BASEDIR=$basedir/$suite_idx-smt/ \
scripts/run-benchmark.sh -mono-app=SMT

banner_run_suite "Scheduling"
NPROCS=32 NTHREADS=1 TIMELIM=120 \
BENCHMARKFILE=scripts/selection-none.txt BASEDIR=$basedir/$suite_idx-scheduling/ \
MPIPARAMS="--oversubscribe" \
scripts/run-benchmark.sh -mono-app=SAT -job-desc-template=$(pwd)/scripts/selection-sat-smoke.txt \
-job-template=templates/tj.json -client-template=templates/tc.json -c=1 \
-J=$(cat $(pwd)/scripts/selection-sat-smoke.txt | wc -l) -ajpc=5 -jwl=60

banner_run_done
