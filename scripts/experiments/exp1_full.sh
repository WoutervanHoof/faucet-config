#!/usr/bin/bash

#! /usr/bin/bash

set -eo pipefail

if [[ $# != 4 ]] ; then
    echo "usage: ./exp1.sh ITERATIONS TIMEOUT ATTEMPT_NUMBER TCP_TIMEOUT"
    exit 1
fi

PI_IPS=("" "10.42.0.10" "10.42.0.170" "10.42.0.179")

iterations="$1"
timeout="$2"
attempt="attempt_$3"

for NUMBER in {1..3} ; do
    ssh "wouter@${PI_IPS[$NUMBER]}" -- docker run -d --rm --tty --net=container:thread-br --volume /usr/share/dumps:/usr/share/dumps tcpdump timeout "$4" tcpdump -i eth0 -w "/usr/share/dumps/exp1/${attempt}_br${NUMBER}.pcap"
    ssh "wouter@${PI_IPS[$NUMBER]}" -- docker run -d --rm --tty --net=container:server --volume /usr/share/dumps:/usr/share/dumps tcpdump timeout "$4" tcpdump -i eth0 -w "/usr/share/dumps/exp1/${attempt}_server${NUMBER}.pcap"
    ssh "wouter@${PI_IPS[$NUMBER]}" -- docker run -d --rm --tty --net=container:attacker --volume /usr/share/dumps:/usr/share/dumps tcpdump timeout "$4" tcpdump -i eth0 -w "/usr/share/dumps/exp1/${attempt}_attacker${NUMBER}.pcap"

    sleep 10

    for CHILD_IP in "fd71:666b:b2e1:bfd9:e8ee:689a:45a6:56" "fd71:666b:b2e1:bfd9:2c24:e30:4428:4b15"; do
        ssh "wouter@${PI_IPS[$NUMBER]}" -- ~/faucet-config/scripts/experiments/exp1.sh "$NUMBER" "$CHILD_IP" "$iterations" "$timeout"
    done
done
