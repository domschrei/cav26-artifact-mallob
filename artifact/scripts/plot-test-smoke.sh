#!/bin/bash

if [ -z $1 ]; then echo "Error: Provide a smoke-test directory to create plots of it" ; exit 1 ; fi
dir="$1"

TIMELIM=1

DIR_SAT_MIXED="$dir/1-sat-mixed"
DIR_SAT_MONOL="$dir/2-sat-monolproof"
DIR_SAT_RTCHECK="$dir/3-sat-rtcheck"
DIR_SAT_STREAML="$dir/4-sat-streamlined"
DIR_INC_DEFAULT="$dir/5-incsat"
DIR_INC_RTCHECK="$dir/6-incsat-rtcheck"
DIR_MAXSAT="$dir/7-maxsat"
DIR_SMT="$dir/8-smt"


outputdir="share/output-$(date +%s)/"
# outputdir="share/output"

mkdir -p "$outputdir"
source scripts/utils.sh

####################################################################################
# [Fig1] Basic CDF plot of all SAT approaches
####################################################################################
python3 scripts/plot_curves.py \
$DIR_SAT_MIXED/cdf.txt -l=Mixed \
$DIR_SAT_MONOL/cdf.txt -l=MonolithicProof \
$DIR_SAT_RTCHECK/cdf.txt -l=RealtimeCheck \
$DIR_SAT_STREAML/cdf.txt -l=Streamlined \
-xy -minx=0 -maxx=$TIMELIM -miny=0 \
-legend-spacing=0.1 -no-markers \
-extend-to-right -gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SAT Smoke Test' \
-sizex=3 -sizey=3 -o=$outputdir/fig1-sat-cdf.pdf


####################################################################################
# [Fig2] Basic CDF plot of all Incremental-SAT approaches
####################################################################################
python3 scripts/plot_curves.py \
$DIR_INC_DEFAULT/cdf.txt -l=Default \
$DIR_INC_RTCHECK/cdf.txt -l=RealtimeCheck \
-xy -minx=0 -maxx=$TIMELIM -miny=0 \
-legend-spacing=0.1 -no-markers \
-extend-to-right -gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='IncSAT Smoke Test' \
-sizex=3 -sizey=3 -o=$outputdir/fig2-incsat-cdf.pdf


####################################################################################
# [Fig3] Basic CDF plot of MaxSat
####################################################################################
python3 scripts/plot_curves.py \
$DIR_MAXSAT/cdf.txt -l=MaxSAT \
-xy -minx=0 -maxx=$TIMELIM -miny=0 \
-legend-spacing=0.1 -no-markers \
-extend-to-right -gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='MaxSAT Smoke Test' \
-sizex=3 -sizey=3 -o=$outputdir/fig3-maxsat-cdf.pdf


####################################################################################
# [Fig4] Basic CDF plot of SMT
####################################################################################
python3 scripts/plot_curves.py \
$DIR_SMT/cdf.txt -l=SMT \
-xy -minx=0 -maxx=$TIMELIM -miny=0 \
-legend-spacing=0.1 -no-markers \
-extend-to-right -gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SMT Smoke Test' \
-sizex=3 -sizey=3 -o=$outputdir/fig4-smt-cdf.pdf



