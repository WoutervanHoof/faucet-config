#! /usr/bin/bash

if [[ $# != 3 ]] ; then
    echo "Usage: ./exp4_get_base.sh BR_NUMBER FILE_BASE_NAME EXPERIMENT_NAME"
    exit 1
fi

number="$1"
filebasename="$2"
experiment_name="$3"

iteration=$(cat count.txt)

ips=("" "10.42.0.10")

echo $( \
    ssh wouter@"${ips[$number]}" -- \
        sudo ovs-ofctl -OOpenFlow13 --no-names --no-stat dump-flows br"$number" \
            | tee "./results_4/${experiment_name}/bridge_${number}_tables_${filebasename}_$(printf "%03d" "$iteration").log" \
            | wc -l \
    ) >> "./results_4/${experiment_name}/bridge_${number}_${filebasename}_table_sizes.log"