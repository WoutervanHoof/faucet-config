#! /usr/bin/bash

set -euxo pipefail

if [[ $# != 2 ]] ; then
    echo "Usage: ./exp4_virtual.sh EXPERIMENT_NAME ITERATIONS"
    exit 1
fi

experiment_name="$1"
iterations="$2"


for size in {01..10} ; do
    mkdir -p "./results_4/${experiment_name}_${size}"
    count=0
    while [[ "$count" != "$iterations" ]] ; do

        echo "$count" > count.txt

        /home/wouter/projects/thesis/faucet-config/scripts/reset_demo.sh "faucet_base_${size}.yaml"

        sleep 6
        
        ./exp4_dump_tables.sh "1" "base" "${experiment_name}_${size}"

        ssh wouter@10.42.0.10 'docker exec thread-br bash -c "echo -n -e \"\x00\x1b\x6d\x75\x64\x66\x69\x6c\x65\x73\x65\x72\x76\x65\x72\x3a\x33\x30\x30\x30\x2f\x6d\x75\x64\x2e\x6a\x73\x6f\x6e\x01\x27\x66\x64\x37\x31\x3a\x36\x36\x36\x62\x3a\x62\x32\x65\x31\x3a\x62\x66\x64\x39\x3a\x34\x34\x65\x61\x3a\x39\x63\x30\x61\x3a\x64\x33\x38\x38\x3a\x36\x34\x61\x65\" > /dev/udp/fd99:aaaa:bbbb:100::1/1234"'

        sleep 6

        ./exp4_dump_tables.sh "1" "mud"  "${experiment_name}_${size}"

        count=$(($count + 1))
    done
done