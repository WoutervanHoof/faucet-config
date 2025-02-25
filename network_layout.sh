#!/bin/bash

get_network_variables() {
    ORM_PREFIX="fd71:666b:b2e1:bfd9::"
    ORM_PREFIX2="fd11:22:1:1::"

    if [[ "$IPversion" = "4" ]] ; then
        PREFIX="10.43.${NUMBER}"
        PREFIX_ROUTE="${PREFIX}.0/24"
        BRIDGE_IP="${PREFIX}.1"
        BRIDGE_ADDRESS="${BRIDGE_IP}/24"
        BORDER_ROUTER_IP="${PREFIX}.2"
        BORDER_ROUTER_SUBNET="${BORDER_ROUTER_IP}/24"
        TEST1_IP="${PREFIX}.3/24"
        TEST2_IP="${PREFIX}.4/24"
    else
        PREFIX="fd99:aaaa:bbbb:${NUMBER}00::"
        PREFIX_ROUTE="${PREFIX}/64"
        BRIDGE_IP="${PREFIX}1"
        BRIDGE_ADDRESS="${BRIDGE_IP}/64"
        BORDER_ROUTER_IP="${PREFIX}2"
        BORDER_ROUTER_SUBNET="${BORDER_ROUTER_IP}/64"
        TEST1_IP="${PREFIX}3/64"
        TEST2_IP="${PREFIX}4/64"
    fi
}