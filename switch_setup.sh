#!/usr/bin/bash

set -euxo pipefail

die () {
	echo $1
	exit 1
}

usage="USAGE: switch_setup.sh IFNAME CONTROLLER_IP"

ifname=$1
controller_ip=$2

if not $(ip link show "$ifname") ; then
	die "$usage; ERROR: IFNAME not found"
fi

if [[ -z "$controller_ip" ]] ; then 
	die "$usage"
fi

if ! $(ip link show wpan0) ; then
	die "Please start Thread, wpan0 is down"
fi

wpan_ips=$(ip -o addr show dev wpan0 | awk '{print $4}')
gateway_ips=$(ip -o addr show dev "$ifname" | awk '{print $4}')
default_ip=$(ip route show | grep 'default' | awk '{print $3}')

sudo ovs-vsctl add-br br0 --may-exist \
	-- set bridge br0 other-config:datapath-id=0000000000000001 \
	-- set bridge br0 fail-mode=secure \
	-- set-controller br0 tcp:"$controller_ip":6653 tcp:"$controller_ip":6654

#for ip in $gateway_ips; do
#	ip addr add "$ip" dev br0
#done

# for ip in $wpan_ips; do
# 	sudo ip addr add "$ip" dev br0
# done

# sudo ip route append default via "$default_ip" dev br0

sudo ovs-vsctl \
#	-- add-port br0 "$ifname" \
# 	-- set interface "$ifname" ofport_request=1 \
	# -- add-port br0 wpan0 \
	# -- set interface wpan0 ofport_request=2