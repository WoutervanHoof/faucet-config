#!/bin/bash

get_network_variables() {
    ORM_PREFIX="fd71:666b:b2e1:bfd9::"

    if [[ "$IPversion" = "4" ]] ; then
        PREFIX="10.43.${NUMBER}"
        BRIDGE_IP="${PREFIX}.1"
        BRIDGE_ADDRESS="${BRIDGE_IP}/24"
        BORDER_ROUTER_IP="${PREFIX}.2/24"
        TEST1_IP="${PREFIX}.3/24"
        TEST2_IP="${PREFIX}.4/24"
    else
        PREFIX="fd99:aaaa:bbbb:${NUMBER}00::"
        BRIDGE_IP="${PREFIX}1"
        BRIDGE_ADDRESS="${BRIDGE_IP}/64"
        BORDER_ROUTER_IP="${PREFIX}2/64"
        TEST1_IP="${PREFIX}3/64"
        TEST2_IP="${PREFIX}4/64"
    fi
}