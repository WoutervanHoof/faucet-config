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

sudo ovs-vsctl --may-exist add-br "$bridge_name"

sudo ip link set "$bridge_name" up

sudo ovs-vsctl --may-exist add-port "$bridge_name" wlan0

sudo ip a flush wlan0
sudo dhclient "$bridge_name"
