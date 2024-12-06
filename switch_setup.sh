#!/bin/bash

device=$1

if [ -z "$device" ]; then
	read -p "Please provide interface name: " device
fi

if ! ip link show dev "$device"  ; then
	echo "Device $device not found"
	exit 1
fi

echo "Device $device"

sudo ip link add dev veth-thread type veth
sudo ip link set veth-thread up

sudo ovs-vsctl add-br br0 \
	-- set bridge br0 other-config:datapath-id=0000000000000001 \
	-- set bridge br0 fail_mode=secure \
	-- add-port br0 veth-thread \
	-- set interface veth-thread ofport_request=1 \
	-- set-controller br0 tcp:10.42.0.1:6653 tcp:10.42.0.1:6654
