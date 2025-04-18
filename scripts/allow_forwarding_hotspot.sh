#! /usr/bin/bash

# Helper script to let my wifi adapter forward traffic
# Allow forwarding things with destination of wlp3s0
sudo iptables -A FORWARD -o wlp3s0 -j ACCEPT
sudo ip6tables -A FORWARD -o wlp3s0 -j ACCEPT

# Allow forwarding things comming from wlp
sudo iptables -A FORWARD -i wlp3s0 -j ACCEPT
sudo ip6tables -A FORWARD -i wlp3s0 -j ACCEPT
