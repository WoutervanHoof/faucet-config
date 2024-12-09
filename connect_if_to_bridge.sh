#! /usr/bin/bash

sudo ip addr add 10.42.0.10/24 dev br0

ip addr del 10.42.0.10/24 dev wlan0

sudo ip link set br0 up

ip route append default via 10.42.0.1 dev br0

sudo ovs-vsctl add-port br0 wlan0
