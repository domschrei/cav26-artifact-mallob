#/bin/bash

if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi
if [ -z $1 ]; then echo "Error: Provide a directory to evaluate" ; exit 1 ; fi

dir="$1"
> $dir/results.txt

if grep -rq "templates/tc.json" $dir/*/ ; then
    # Scheduled run (many instances solved in one run of Mallob)

    grep -hr "Reading job" $dir/1/*/log.*.reader | grep -oE "\{.*\}" | sed 's/{//g;s/}//g'\
     > $dir/commands.txt

    grep -hoE "[0-9\.]+ [0-9]+ RESPONSE_TIME #[0-9]+ [0-9\.]+ " $dir/1/*/log.* | awk '{print $4,"solved",$5}'\
     >> $dir/results.txt
    grep -hoE "[0-9\.]+ [0-9]+ TIMEOUT/UNKNOWN #[0-9]+ " $dir/1/*/log.* | awk '{print $4,"UNKNOWN",'$TIMELIM'}'\
     >> $dir/results.txt

    grep -hoE "[0-9\.]+ [0-9]+ RESPONSE_TIME #[0-9]+ [0-9\.]+ " $dir/1/*/log.* | awk '{print $5}'\
     | sort -g | awk 'BEGIN{print 0,0} {print $1,(NR-1); print $1,NR}' > $dir/cdf.txt

    grep -hoE "[0-9\.]+ [0-9]+ RESPONSE_TIME #[0-9]+ [0-9\.]+ " $dir/1/*/log.* | awk '{print $1}'\
     | sort -g | awk 'BEGIN{print 0,0} {print $1,(NR-1); print $1,NR}' > $dir/cdf-accumulated.txt

    exit
fi

# "Mono" runs (one instance processed per Mallob run)

> $dir/solvedqueries.txt
for d in $dir/*/ ; do

    id=$(basename $d)
    if [ -d /app/benchmarks/ ]; then
      inst=$(grep -oP '"/app/benchmarks/.*?"' $d/0/log.0 | sed 's/"//g')
    else
      inst=$(grep -oP '"../benchmarks/.*?"' $d/0/log.0 | sed 's/"//g' | cut -c 4-)
    fi

    if ! [ -z "$inst" ]; then id="$inst"; fi

    time="$TIMELIM"
    res="UNKNOWN"
    cost=x
    chktime=0
    nsolved=0

    fres="$d/res.txt"
    if [ -f "$fres" ] ; then

        if grep -qE "^s SATISFIABLE" $fres ; then
            res="SATISFIABLE"
        elif grep -qE "^s UNSATISFIABLE" $fres ; then
            res="UNSATISFIABLE"
        elif grep -qE "^s OPTIMUM FOUND" $fres ; then
            res="OPTIMUM_FOUND"
        fi

        if cat $fres|grep -q "total_response_time" ; then
            time=$(cat $fres|grep "total_response_time"|awk '{print $3}')
        elif grep -q "RESPONSE_TIME" $d/0/log.0 ; then
            time=$(grep -oE "RESPONSE_TIME #[0-9]+ [0-9\.]+" $d/0/log.0 | awk '{print $3}' | sort -g | tail -1)
        fi

        # if (( $(echo "$time >= $TIMELIM" | bc -l) )); then  #bc not default available on all platforms
        if awk "BEGIN {exit !($time >= $TIMELIM)}"; then
            res="UNKNOWN"
        fi

        fchk="$d/chk.txt"
        if [ -f "$fchk" ] ; then
            if grep -qE "^s VERIFIED$" "$fchk"; then
                chktime=$(grep "Exiting happily" $fchk|awk '{print $2}')
            else
                res="ERROR"
                time="$TIMELIM"
            fi
        fi

        if grep -qE "^o [0-9]+" $fres ; then
            cost=$(grep -oE "^o [0-9]+" $fres | awk '{print $2}')
        fi
    fi

    echo "$id $res $time $cost $chktime" >> $dir/results.txt

    if ! [ -z "$inst" ] && [ -f "$(dirname "$inst")/../best-known-costs.txt" ]; then
        bestknowncost=$(grep -E "^$(basename $inst).xz " $(dirname "$inst")/../best-known-costs.txt | awk '{print $2}' | grep -oE "[0-9]+")
        if ! [ -z "$bestknowncost" ]; then
            grep -oE '^c [0-9\.]+ 0 .* new bounds: \([0-9]+,[0-9]+\)' $d/0/log.0 | awk '{print $2,$NF}' | sed 's/(//g;s/)//g;s/,/ /g'\
             | awk 'BEGIN {l=1/('$bestknowncost'+1); u=0} {nl=($2+1)/('$bestknowncost'+1); nu=('$bestknowncost'+1)/($3+1); print $1, l, u, nl, nu; l=nl; u=nu}' > $d/cost-progression.txt
        fi
    fi

    fsmt="$d/out.smt2"
    if [ -f "$fsmt" ]; then
        nsolved=$(grep -E "^(un)?sat$" $fsmt | wc -l)
        if [ ! -f "$inst" ]; then
            xz -dk "$inst.xz"
        fi
        nqueries=$(grep '(check-sat)' $inst | wc -l)
         # if (( $(echo "$time >= $TIMELIM" |bc -l) )); then  #replaced bc with awk
        if awk "BEGIN {exit !($time >= $TIMELIM)}"; then
            res="UNKNOWN"
        fi
    else
        # number of solved Mallob task minus one (the "top-level" task)
        nsolved=$(( $(grep "RESPONSE_TIME" $d/0/log.0 | wc -l) - 1))
    fi
    echo "$id $nsolved" >> $dir/solvedqueries.txt
done

touch .empty
cat .empty $(find $dir/*/ -name 'cost-progression.txt') | sort -g | awk '{l=l-$2+$4; u=u-$3+$5; print $1,l,u}' > $dir/cost-sum-progression.txt

cat $dir/results.txt | awk '$2 != "UNKNOWN" && $3 < '$TIMELIM' {print $3}' | sort -g\
 | awk 'BEGIN{print 0,0} {print $1,(NR-1); print $1,NR}' > $dir/cdf.txt
