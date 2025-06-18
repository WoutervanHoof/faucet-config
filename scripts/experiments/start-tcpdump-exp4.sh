#!/bin/sh
rm -f nohup.out
nohup tcpdump -ni eth0 -w "/usr/share/dumps/exp4/single_$(date +%F_%T).pcap" &

# Write tcpdump's PID to a file
echo $! > /var/run/tcpdump.pid
