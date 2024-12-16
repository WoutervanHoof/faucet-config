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
    ip addr flush dev "$BRIDGE" || true
    ovs-vsctl --if-exists del-br "$BRIDGE"
}

test_up() {
    docker run -d --name="$TEST_NAME"1 --net=none nginx:alpine
    docker run -d --name="$TEST_NAME"2 --net=none nginx:alpine

    ovs-docker add-port "$BRIDGE" eth0 "$TEST_NAME"1 --ipaddress="$TEST1_IP" --gateway="$BRIDGE_IP"
    ovs-docker add-port "$BRIDGE" eth0 "$TEST_NAME"2 --ipaddress="$TEST2_IP" --gateway="$BRIDGE_IP"
}

test_down(){
    ovs-docker del-port "$BRIDGE" eth0 "$TEST_NAME"1 || true
    ovs-docker del-port "$BRIDGE" eth0 "$TEST_NAME"2 || true

    docker stop "$TEST_NAME"1 "$TEST_NAME"2 || true
    docker rm "$TEST_NAME"1 "$TEST_NAME"2 || true
    
}

border_router_up() {
    modprobe ip6table_filter

    docker run -d --name="thread-br" --sysctl "net.ipv6.conf.all.disable_ipv6=0 net.ipv4.conf.all.forwarding=1 net.ipv6.conf.all.forwarding=1" -p 8080:80 --dns=127.0.0.1 -it --volume /dev/ttyACM0:/dev/ttyACM0 --privileged openthread/otbr --radio-url spinel+hdlc+uart:///dev/ttyACM0
}

border_router_down() {
    docker stop thread_br || true
    docker rm "thread-br" || true
}


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

NAME=$(basename "$0")
if (ip netns) > /dev/null 2>&1; then :; else
    echo >&2 "$NAME: ip utility not found (or it does not support netns),"\
             "cannot proceed"
    exit 1
fi

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

TEST=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        up)
            bridge_up

            if [ $TEST ] ; then
                test_up
            fi
            
            border_router_up
            
            exit 0
            ;;
        down)
            bridge_down

            if docker ps | grep "$TEST_NAME" > /dev/null ; then
                test_down
            fi

            border_router_down

            exit 0
            ;;
        -t | --test)
            TEST=1
            shift
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
done