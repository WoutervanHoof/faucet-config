#!/bin/bash

get_network_layout() {
    if [[ "$NUMBER" == "1" ]] ; then 
        VLAN_PREFIX="fd99:aaaa:bbbb"
    elif [[ "$NUMBER" == "2" ]] ; then
        VLAN_PREFIX="fd99:aaaa:cccc"
    else
        echo "unspecified number: $NUMBER"
        exit 1
    fi

    export OMR_PREFIX="fd71:666b:b2e1:bfd9::"
    export VLANS_ROUTE="${VLAN_PREFIX}::/48"

    export BORDER_ROUTER_VLAN="${VLAN_PREFIX}:100::"
    export BORDER_ROUTER_PREFIX_ROUTE="${BORDER_ROUTER_VLAN}/64"
    export BORDER_ROUTER_FAUCET_VIP="${BORDER_ROUTER_VLAN}1"
    export BORDER_ROUTER_IP="${BORDER_ROUTER_VLAN}2"
    export BORDER_ROUTER_SUBNET="${BORDER_ROUTER_IP}/64"

    export SERVER_VLAN="${VLAN_PREFIX}:200::"
    export SERVER_PREFIX_ROUTE="${SERVER_VLAN}/64"
    export SERVER_FAUCET_VIP="${SERVER_VLAN}1"
    export SERVER_IP="${SERVER_VLAN}2"
    export SERVER_SUBNET="${SERVER_IP}/64"

    export ATTACKER_VLAN="${VLAN_PREFIX}:300::"
    export ATTACKER_PREFIX_ROUTE="${ATTACKER_VLAN}/64"
    export ATTACKER_FAUCET_VIP="${ATTACKER_VLAN}1"
    export ATTACKER_IP="${ATTACKER_VLAN}2"
    export ATTACKER_SUBNET="${ATTACKER_IP}/64"
}
