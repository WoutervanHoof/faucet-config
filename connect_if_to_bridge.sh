#! /usr/bin/bash

set -euxo pipefail

sudo ip addr add 10.42.0.10/24 dev br0

sudo ip addr del 10.42.0.10/24 dev wlan0

sudo ip link set br0 up

sudo ip route append default via 10.42.0.1 dev br0

sudo ovs-vsctl add-port br0 wlan0
