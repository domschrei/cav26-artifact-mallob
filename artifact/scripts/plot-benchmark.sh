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
for d in $(echo $dir/*-sat-* | sort) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SAT solving performance' \
-sizex=3 -sizey=3 -o=$outputdir/sat-cdf.pdf >> $outputdir/plotting-logs.txt

# INCSAT
input=""
for d in $(echo $dir/*-incsat* | sort) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='Incremental SAT performance' \
-sizex=3 -sizey=3 -o=$outputdir/incsat-cdf.pdf >> $outputdir/plotting-logs.txt

# MAXSAT
input=""
for d in $(echo $dir/*-maxsat* | sort) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='MaxSAT performance' \
-sizex=3 -sizey=3 -o=$outputdir/maxsat-cdf.pdf >> $outputdir/plotting-logs.txt

# SMT
input=""
for d in $(echo $dir/*-smt* | sort) ; do
    input="$input $d/cdf.txt -l=$(echo $(basename $d) | grep -oE 'c[0-9]+-.*') "
done
python3 scripts/plot_curves.py \
$input -xy -minx=0 -maxx=$TIMELIM -miny=0 \
-extend-to-right -legend-spacing=0 -no-markers \
-gridx -gridy -labelx='Running time $t$ [s]' -labely='\# instances solved in $\leq$ t' \
-title='SMT performance' \
-sizex=3 -sizey=3 -o=$outputdir/smt-cdf.pdf >> $outputdir/plotting-logs.txt

####################################################################################
# TABLES
####################################################################################

# SAT
(
echo "_ overall _ satisf. _ unsatisf. _"
echo "Run #solved PAR2 #solved avgtime #solved avgtime"
for d in $dir/*-sat-* ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    cat $d/results.txt | awk '$3 < '$TIMELIM' && $2 == "SATISFIABLE" {nsat+=1; ssat+=$3}\
      $3 < '$TIMELIM' && $2 == "UNSATISFIABLE" {nunsat+=1; sunsat+=$3}\
      END {print "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat+nunsat, (ssat+sunsat + ('$nbenchs'-nsat-nunsat)*2*'$TIMELIM')/('$nbenchs'), nsat, ssat/nsat, nunsat, sunsat/nunsat}'
done | sort
) | column -t > $outputdir/table-sat.txt

# INCSAT
(
echo "Run #fullysolved PAR2 #solvedqueries"
for d in $dir/*-incsat* ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    cat $d/results.txt | awk '$3 < '$TIMELIM' && $2 == "SATISFIABLE" {nsat+=1; ssat+=$3}\
      $3 < '$TIMELIM' && $2 == "UNSATISFIABLE" {nunsat+=1; sunsat+=$3}\
      END {printf "%s %i %.1f ", "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat+nunsat, \
      (ssat+sunsat + ('$nbenchs'-nsat-nunsat)*2*'$TIMELIM')/('$nbenchs')}'
    cat $d/solvedqueries.txt | awk '{s+=$2} END {print s}'
done | sort
) | column -t > $outputdir/table-incsat.txt

# MaxSAT
(
echo "Run #optsolved PAR2 avgtime"
for d in $dir/*-maxsat* ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    cat $d/results.txt | awk '$3 < '$TIMELIM' && ($2 == "SATISFIABLE" || $2 == "OPTIMUM_FOUND") {nsat+=1; ssat+=$3}\
      END {print "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat, (ssat + ('$nbenchs'-nsat)*2*'$TIMELIM')/('$nbenchs'), nsat, ssat/nsat}'
done | sort
) | column -t > $outputdir/table-maxsat.txt

# SMT
(
echo "Run #fullysolved PAR2 #solvedqueries"
for d in $dir/*-smt* ; do
    nbenchs=$(cat $d/commands.txt | wc -l)
    cat $d/results.txt | awk '$3 < '$TIMELIM' && ($2 == "SATISFIABLE" || $2 == "UNSATISFIABLE") {nsat+=1; ssat+=$3}\
      END {printf "%s %i %.1f ", "'$(basename $d | grep -oE 'c[0-9]+-.*')'", nsat, \
      (ssat + ('$nbenchs'-nsat)*2*'$TIMELIM')/('$nbenchs')}'
    cat $d/solvedqueries.txt | awk '{s+=$2} END {print s}'
done | sort
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
