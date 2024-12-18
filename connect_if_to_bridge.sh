#! /usr/bin/bash

set -euxo pipefail

for id in $(ps -A | grep dhclient | grep -o -E '[0-9][0-9][0-9][0-9]') ; do
    sudo kill "$id"
done

sudo ip link set ovsbridge up

sudo ovs-vsctl add-port ovsbridge wlan0

sudo ip a flush wlan0
sudo dhclient ovsbridge 

sudo ip route append default via 10.42.0.1 dev ovsbridge
