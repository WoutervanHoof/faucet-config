#!/bin/bash

if [[ $# != 1 ]] ; then
    echo "missing required argument. Usage: ./start_tcpdump-exp4.sh File_Base_Name"
fi

filename=$1

sudo rm -f nohup.out
sudo nohup tcpdump -i wlan0 -w "/usr/share/dumps/exp4/${filename}_$(date +%F_%T).pcap" >> /home/wouter/tcpdump$(date +%F_%T).log 2>&1 &

# Write tcpdump's PID to a file
sudo echo $! > /home/wouter/tcpdump.pid
