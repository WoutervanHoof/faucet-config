#! /usr/bin/bash

# Allow forwarding things with destination of wlp3s0
sudo iptables -A FORWARD -o wlp3s0 -j ACCEPT
# Allow forwarding things comming from wlp
sudo iptables -A FORWARD -i wlp3s0 -j ACCEPT
