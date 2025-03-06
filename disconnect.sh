#! /usr/bin/bash

set -euxo pipefail

bridge_name=$1

if [ -z "${bridge_name+x}" ] ; then
    echo "usage: connect_if_to_bridge.sh BRIDGE_NAME"
    exit 1
fi

for id in $(ps -A | grep dhclient | grep -o -E '^  ([0-9]*)') ; do
   sudo kill "$id"
done

sudo ip link set wlan0 up

sudo ovs-vsctl del-port "$bridge_name" wlan0

sudo ip a flush "$bridge_name"

sudo ip a flush wlan0

sudo dhclient wlan0

#sudo ip route append default via 10.42.0.1 dev wlan0
