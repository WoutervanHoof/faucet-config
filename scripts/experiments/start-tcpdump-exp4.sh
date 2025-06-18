#!/bin/sh
sudo rm -f nohup.out
sudo nohup tcpdump -i wlan0 -w "/usr/share/dumps/exp4/single_$(date +%F_%T).pcap" &

# Write tcpdump's PID to a file
sudo echo $! > /var/run/tcpdump.pid
