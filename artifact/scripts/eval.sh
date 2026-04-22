#/bin/bash

if [ -z $TIMELIM ]; then echo "Error: \$TIMELIM not provided" ; exit 1 ; fi
if [ -z $1 ]; then echo "Error: Provide a directory to evaluate" ; exit 1 ; fi

dir="$1"

> $dir/times.txt
> $dir/solvedqueries.txt
for d in $dir/*/ ; do
    fres="$d/res.txt"
    fsmt="$d/out.smt2"
    if [ ! -f "$fres" ] || [ ! -f "$fsmt" ]; then
        echo "Warning: Unexpectedly missing file $fres or $fsmt"
        continue
    fi
    id=$(basename $d)
    nsolved=$(grep -E "^(un)?sat$" $fsmt | wc -l)
    if [ $nsolved == 0 ]; then
        echo "$id $TIMELIM" >> $dir/times.txt
        echo "$id 0" >> $dir/solvedqueries.txt
        continue
    fi
    echo "$id $nsolved" >> $dir/solvedqueries.txt
    if grep -qE "^unknown$" $fsmt ; then
        echo "$id $TIMELIM" >> $dir/times.txt
        continue
    fi
    if ! cat $fres|grep -q "total_response_time" ; then
        echo "$id $TIMELIM" >> $dir/times.txt
        continue
    fi
    time=$(cat $fres|grep "total_response_time"|awk '{print $3}')
    echo "$id $time" >> $dir/times.txt
done

sort -k 1,1b $dir/times.txt -o $dir/times.txt
join --check-order $dir/times.txt $dir/commands.txt | sed 's,/.*/SMT-LIB/,SMT-LIB/,g' \
    | awk '{print $NF,$2}' | sort -k 1,1b > $dir/qtimes.txt

sort -k 1,1b $dir/solvedqueries.txt -o $dir/solvedqueries.txt
join --check-order $dir/solvedqueries.txt $dir/commands.txt | sed 's,/.*/SMT-LIB/,SMT-LIB/,g' \
    | awk '{print $NF,$2}' > $dir/qsolvedqueries.txt

cat $dir/qtimes.txt | awk '$2 < '$TIMELIM' {print $2}' | sort -g | awk 'BEGIN{print 0,0} {print $1,NR}' > $dir/cdf.txt
