#/bin/bash

if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi
if [ -z $1 ]; then echo "Error: Provide a directory to evaluate" ; exit 1 ; fi

dir="$1"

> $dir/results.txt
> $dir/solvedqueries.txt
for d in $dir/*/ ; do

    id=$(basename $d)
    if [ "$NODOCKER" -eq "1" ]; then
      inst=$(grep -oP '"../benchmarks/.*?"' $d/0/log.0 | sed 's/"//g' | cut -c 4-)
    else
      inst=$(grep -oP '"/app/benchmarks/.*?"' $d/0/log.0 | sed 's/"//g')
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
        if (( $(echo "$time >= $TIMELIM" |bc -l) )); then
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

    fsmt="$d/out.smt2"
    if [ -f "$fsmt" ]; then
        nsolved=$(grep -E "^(un)?sat$" $fsmt | wc -l)
        if [ ! -f "$inst" ]; then
            xz -dk "$inst.xz"
        fi
        nqueries=$(grep '(check-sat)' $inst | wc -l)
        if (( $(echo "$time >= $TIMELIM" |bc -l) )); then
            res="UNKNOWN"
        fi
    fi
    echo "$id $nsolved" >> $dir/solvedqueries.txt
done

cat $dir/results.txt | awk '$2 != "UNKNOWN" && $3 < '$TIMELIM' {print $3}' | sort -g\
 | awk 'BEGIN{print 0,0} {print $1,NR}' > $dir/cdf.txt
