#!/bin/bash

# Setup or tear down an OVS switch
# For testing purposes, add 2 docker containers
# Add the Border Router
# Add an internet connected interface

# . ./ovs-docker_copy.sh

set -euxo pipefail

BRIDGE="br0"
TEST_NAME="br_test"

CONTROLLER_IP="10.42.0.1"
BRIDGE_IP="192.168.2.1"
TEST1_IP="192.168.2.3/24"
TEST2_IP="192.168.2.4/24"

# Create bridge, set controller to "$CONTROLLER_IP" (TODO: allow setting IP)
bridge_up() {
    ovs-vsctl --may-exist add-br "$BRIDGE" \
        -- set bridge "$BRIDGE" other-config:datapath-id=0000000000000001 \
        -- set bridge "$BRIDGE" other-config:disable-in-band=true \
        -- set bridge "$BRIDGE" fail_mode=secure \
        -- set-controller "$BRIDGE" tcp:${CONTROLLER_IP}:6653 tcp:${CONTROLLER_IP}:6654
    
    ip addr add "$BRIDGE_IP"/24 brd + dev "$BRIDGE"
}

bridge_down() {
    ip addr flush dev "$BRIDGE"
    ovs-vsctl del-br "$BRIDGE"
}

test_up() {
    docker run -d --name="$TEST_NAME"1 --net=none alpine
    docker run -d --name="$TEST_NAME"2 --net=none alpine

    ovs-docker add-port "$BRIDGE" eth0 "$TEST_NAME"1 --ipaddres="$TEST1_IP" --gateway="$BRIDGE_IP"
    ovs-docker add-port "$BRIDGE" eth0 "$TEST_NAME"2 --ipaddres="$TEST2_IP" --gateway="$BRIDGE_IP"
}

test_down(){
    ovs-docker del-port "$BRIDGE" "$TEST_NAME"1
    ovs-docker del-port "$BRIDGE" "$TEST_NAME"2

    docker stop br_test1 br_test2
    docker rm br_test1 br_test2
    
}

UTIL=$(basename $0)
search_path ovs-vsctl
search_path docker

if (ip netns) > /dev/null 2>&1; then :; else
    echo >&2 "$UTIL: ip utility not found (or it does not support netns),"\
             "cannot proceed"
    exit 1
fi

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

usage() {
    cat <<-EOF
        ${NAME}: Sets up the demo environment for MultiMUD (TODO title).
        usage: ${NAME} [OPTION] COMMAND

        Commands:
        up                  Run all components

        down                Remove all components
        
        Options:
        -h, --help          display this help message.
        --test              Add two docker containers to the bridge for testing
EOF
}

NAME=$(basename $0)
TEST=0
case $1 in
    up)
        bridge_up

        if $TEST ; then
            test_up
        fi
        
        exit 0
        ;;
    down)
        bridge_down

        if $(docker ps | grep "$TEST_NAME") ; then
            test_down
        fi

        exit 0
        ;;
    -t | --test)
        $TEST=1
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo >&2 "$UTIL: unknown command \"$1\" (use -h, --help for help)"
        exit 1
        ;;
esac