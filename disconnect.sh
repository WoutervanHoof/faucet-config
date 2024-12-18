#! /usr/bin/bash

for id in $(ps -A | grep dhclient | grep -o -E '[0-9][0-9][0-9][0-9]') ; do
    sudo kill "$id"
done

sudo ip link set wlan0 up

sudo ovs-vsctl del-port ovsbridge wlan0

sudo ip a flush ovsbridge
sudo ip a flush wlan0
sudo dhclient wlan0 

sudo ip route append default via 10.42.0.1 dev wlan0
