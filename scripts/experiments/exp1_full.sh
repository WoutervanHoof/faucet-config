#!/usr/bin/bash

#! /usr/bin/bash

set -eo pipefail

source ../network_layout.sh

if [[ $# != 2 ]] ; then
    echo "usage: ./exp1.sh ITERATIONS TIMEOUT"
    exit 1
fi

PI_IPS=("" "10.42.0.10" "10.42.0.170" "10.42.0.179")

iterations="$1"
timeout="$2"

for NUMBER in {1..3} ; do
    for CHILD_IP in "fd71:666b:b2e1:bfd9:2c24:e30:4428:4b15" "fd71:666b:b2e1:bfd9:e8ee:689a:45a6:56" ; do
        ssh "wouter@${PI_IPS[$NUMBER]}" -- ~/faucet-config/scripts/experiments/exp1.sh "$NUMBER" "$CHILD_IP" "$iterations"
    done
done

