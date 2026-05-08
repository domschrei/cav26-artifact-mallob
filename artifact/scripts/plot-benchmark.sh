#!/bin/bash

if [ -z $1 ]; then echo "Error: Provide a directory to create plots for" ; exit 1 ; fi
dir="$1"

if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi

outputdir="$dir/output-$(date +%s)/"
mkdir -p "$outputdir"
> $outputdir/plotting-logs.txt

####################################################################################
# CDF PLOTS
####################################################################################

# SAT
input=""
for d in $(echo $dir/*-sat-* | tr ' ' '\n' | sort -V | tac) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SAT solving performance' \
-sizex=3 -sizey=3 -o=$outputdir/sat-cdf.pdf >> $outputdir/plotting-logs.txt
python3 scripts/plot_curves.py \
$input -xy -logx -minx=0.01 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SAT solving performance' \
-sizex=3 -sizey=3 -o=$outputdir/sat-cdf-logscale.pdf >> $outputdir/plotting-logs.txt

# INCSAT
input=""
for d in $(echo $dir/*-incsat* | tr ' ' '\n' | sort -V | tac) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='Incremental SAT performance' \
-sizex=3 -sizey=3 -o=$outputdir/incsat-cdf.pdf >> $outputdir/plotting-logs.txt
python3 scripts/plot_curves.py \
$input -xy -logx -minx=0.01 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='Incremental SAT performance' \
-sizex=3 -sizey=3 -o=$outputdir/incsat-cdf-logscale.pdf >> $outputdir/plotting-logs.txt

# MAXSAT
input=""
for d in $(echo $dir/*-maxsat* | tr ' ' '\n' | sort -V | tac) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='MaxSAT performance' \
-sizex=3 -sizey=3 -o=$outputdir/maxsat-cdf.pdf >> $outputdir/plotting-logs.txt
python3 scripts/plot_curves.py \
$input -xy -logx -minx=0.01 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='MaxSAT performance' \
-sizex=3 -sizey=3 -o=$outputdir/maxsat-cdf-logscale.pdf >> $outputdir/plotting-logs.txt

# SMT
input=""
for d in $(echo $dir/*-smt* | tr ' ' '\n' | sort -V | tac) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SMT performance' \
-sizex=3 -sizey=3 -o=$outputdir/smt-cdf.pdf >> $outputdir/plotting-logs.txt
python3 scripts/plot_curves.py \
$input -xy -logx -minx=0.01 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SMT performance' \
-sizex=3 -sizey=3 -o=$outputdir/smt-cdf-logscale.pdf >> $outputdir/plotting-logs.txt

# MaxSAT cost progression
for B in lb ub ; do
input=""
for d in $(echo $dir/*-maxsat* | tr ' ' '\n' | sort -V | tac) ; do
    cat $d/cost-sum-progression.txt | awk '{print $1,$2}' > $d/.plot.lb
    cat $d/cost-sum-progression.txt | awk '{print $1,$3}' > $d/.plot.ub
    input="$input $d/.plot.$B -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='Accumulated bound quality' \
-title='MaxSAT quality progression: '$B \
-sizex=3 -sizey=3 -o=$outputdir/maxsat-quality-$B.pdf >> $outputdir/plotting-logs.txt
done


####################################################################################
# TABLES
####################################################################################

# SAT
(
echo "_ overall _ satisf. _ unsatisf. _"
echo "Run #solved PAR2 #solved avgtime #solved avgtime"
for d in $(echo $dir/*-sat-* | tr ' ' '\n' | sort -V) ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    cat $d/results.txt | awk '$3 < '$TIMELIM' && $2 == "SATISFIABLE" {nsat+=1; ssat+=$3}\
      $3 < '$TIMELIM' && $2 == "UNSATISFIABLE" {nunsat+=1; sunsat+=$3}\
      END {print "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat+nunsat, (ssat+sunsat + ('$nbenchs'-nsat-nunsat)*2*'$TIMELIM')/('$nbenchs'), nsat, ssat/nsat, nunsat, sunsat/nunsat}'
done
) | column -t > $outputdir/table-sat.txt

# INCSAT
(
echo "Run #fullysolved PAR2 #solvedqueries"
for d in $(echo $dir/*-incsat* | tr ' ' '\n' | sort -V) ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    cat $d/results.txt | awk '$3 < '$TIMELIM' && $2 == "SATISFIABLE" {nsat+=1; ssat+=$3}\
      $3 < '$TIMELIM' && $2 == "UNSATISFIABLE" {nunsat+=1; sunsat+=$3}\
      END {printf "%s %i %.1f ", "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat+nunsat, \
      (ssat+sunsat + ('$nbenchs'-nsat-nunsat)*2*'$TIMELIM')/('$nbenchs')}'
    cat $d/solvedqueries.txt | awk '{s+=$2} END {print s}'
done
) | column -t > $outputdir/table-incsat.txt

# MaxSAT
(
echo "Run #optsolved PAR2 avgtime LB-score UB-score"
for d in $(echo $dir/*-maxsat* | tr ' ' '\n' | sort -V) ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    score_lb=$(cat $d/cost-sum-progression.txt | tail -1 | awk '{print $2}')
    score_ub=$(cat $d/cost-sum-progression.txt | tail -1 | awk '{print $3}')
    cat $d/results.txt | awk 'BEGIN{nsat=0; ssat=0} $3 < '$TIMELIM' && ($2 == "SATISFIABLE" || $2 == "OPTIMUM_FOUND") {nsat+=1; ssat+=$3}\
      END {print "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat, (ssat + ('$nbenchs'-nsat)*2*'$TIMELIM')/('$nbenchs'), nsat, (nsat==0)?0:(ssat/nsat), '$score_lb', '$score_ub'}'
done
) | column -t > $outputdir/table-maxsat.txt

# SMT
(
echo "Run #fullysolved PAR2 #solvedqueries"
for d in $(echo $dir/*-smt* | tr ' ' '\n' | sort -V) ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    cat $d/results.txt | awk '$3 < '$TIMELIM' && ($2 == "SATISFIABLE" || $2 == "UNSATISFIABLE") {nsat+=1; ssat+=$3}\
      END {printf "%s %i %.1f ", "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat, \
      (ssat + ('$nbenchs'-nsat)*2*'$TIMELIM')/('$nbenchs')}'
    cat $d/solvedqueries.txt | awk '{s+=$2} END {print s}'
done
) | column -t > $outputdir/table-smt.txt

####################################################################################
# Proof checking overheads
####################################################################################

for d in $dir/*-sat-monolproof* ; do
    d_mixed=$(dirname $d)/*-$(basename $d|grep -oE "c[0-9]+")-sat-mixed
    d_rtchk=$(dirname $d)/*-$(basename $d|grep -oE "c[0-9]+")-sat-rtcheck

    cat $d/results.txt | grep " UNSATISFIABLE " | awk '{print $1,"x",$3}' > .1v1-a
    cat $d/results.txt | grep " UNSATISFIABLE " | awk '{print $1,"x",$5}' > .1v1-b
    python3 scripts/plot_1v1.py .1v1-a -l="Solving time [s]" .1v1-b -l="Checking time [s]" \
    -h="$(basename $d)" \
    -logscale -min=0.001 -T=$TIMELIM -max=$(( (3*$TIMELIM)/2 )) -o=$outputdir/1v1-overhead-solve-vs-check-$(basename $d).pdf >> $outputdir/plotting-logs.txt

    cat $d_mixed/results.txt | grep " UNSATISFIABLE " | awk '{print $1,"x",$3}' > .1v1-a
    cat $d/results.txt | grep " UNSATISFIABLE " | awk '{print $1,"x",$3+$5}' > .1v1-b
    python3 scripts/plot_1v1.py .1v1-a -l="Solving time w/ mixed portfolio [s]" \
    .1v1-b -l="Solving + checking time [s]" -h=Monolithic \
    -logscale -min=0.001 -T=$TIMELIM -max=$(( (3*$TIMELIM)/2 )) -o=$outputdir/1v1-overhead-over-mixed-$(basename $d).pdf >> $outputdir/plotting-logs.txt

    cat $d_mixed/results.txt | grep " UNSATISFIABLE " | awk '{print $1,"x",$3}' > .1v1-a
    cat $d_rtchk/results.txt | grep " UNSATISFIABLE " | awk '{print $1,"x",$3}' > .1v1-b
    python3 scripts/plot_1v1.py .1v1-a -l="Solving time w/ mixed portfolio [s]" \
    .1v1-b -l="Solving + checking time [s]" -h="Real-time checking" \
    -logscale -min=0.001 -T=$TIMELIM -max=$(( (3*$TIMELIM)/2 )) -o=$outputdir/1v1-overhead-$(basename $d | sed 's/monolproof/rtcheck/g').pdf >> $outputdir/plotting-logs.txt
done


echo "####################################################################################"
echo "All output written to $outputdir" 
echo "####################################################################################"
