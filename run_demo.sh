#!/bin/bash

# Setup or tear down an OVS switch
# For testing purposes, add 2 docker containers
# Add the Border Router
# Add an internet connected interface

# . ./ovs-docker_copy.sh

set -euxo pipefail

. ./network_layout.sh

# Create bridge, set controller to "$CONTROLLER_IP" (TODO: allow setting IP)
bridge_up() {
    ovs-vsctl --may-exist add-br "$BRIDGE" \
        -- set bridge "$BRIDGE" other-config:datapath-id=000000000000000"$NUMBER" \
        -- set bridge "$BRIDGE" other-config:disable-in-band=true \
        -- set bridge "$BRIDGE" fail_mode=secure \
        -- set-controller "$BRIDGE" "tcp:${CONTROLLER_IP}:6653" "tcp:${CONTROLLER_IP}:6654"
    
    ip addr add "$BRIDGE_ADDRESS" dev "$BRIDGE"
}

bridge_down() {
    ip addr flush dev "$BRIDGE" || true
    ovs-vsctl --if-exists del-br "$BRIDGE"
}

test_up() {
    # We disable accept_ra and autoconf to block the borderrouters from spreading ips.
    # Those IPs mess up the preconfigured routes
    docker run -d --name="$TEST_NAME"1 --net=none --cap-add NET_ADMIN --sysctl "net.ipv6.conf.all.disable_ipv6=0" --sysctl "net.ipv6.conf.all.autoconf=0 net.ipv6.conf.all.accept_ra=0" --sysctl "net.ipv6.conf.default.autoconf=0" --sysctl "net.ipv6.conf.default.accept_ra=0" --volume "$dumps_dir":"$dumps_dir" nicolaka/netshoot /bin/bash -c "while true; do sleep 60; done"
    docker run -d --name="$TEST_NAME"2 --net=none --cap-add NET_ADMIN --sysctl "net.ipv6.conf.all.disable_ipv6=0" --volume "$dumps_dir":"$dumps_dir" nginx:alpine

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

    if [[! -f "/dev/ttyACM0" ]] ; then
        echo "/dev/ttyACM0 does not exist, exiting..."
        exit 1
    fi

    docker run -d --name="thread-br" --net=none \
	    --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
	    --sysctl "net.ipv4.conf.all.forwarding=1" \
	    --sysctl "net.ipv6.conf.all.forwarding=1" \
	    -p 8080:80 --dns=172.0.0.1 -it \
	    --volume /dev/ttyACM0:/dev/ttyACM0 \
	    --volume "$dumps_dir":"$dumps_dir" \
	    --privileged \
	    wouter/otbr-pi \
	    --radio-url "spinel+hdlc+uart:///dev/ttyACM0?uart-baudrate=115200&uart-flow-control"

    ovs-docker add-port "$BRIDGE" eth0 thread-br --ipaddress="$BORDER_ROUTER_SUBNET" --gateway="$BRIDGE_IP"
}

border_router_down() {
    ovs-docker del-port "$BRIDGE" eth0 thread-br || true

    docker stop "thread-br" || true
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
        -t, --test          Add two docker containers to the bridge for testing
        -n, --number        Sets the number used to identify the border router. This sets both the IPv6 network submask as well as the datapath-id for OVS
EOF
}

NAME=$(basename "$0")
if (ip netns) > /dev/null 2>&1; then :; else
    echo >&2 "$NAME: ip utility not found (or it does not support netns),"\
             "cannot proceed"
    exit 1
fi

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

TEST=0
UP=""
DOWN=""
NUMBER=""
IPversion="6"
BRIDGE=""
BRIDGE_NAME=""
BRIDGE_ONLY="0"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        up)
            UP="1"
            shift
            ;;
        down)
            DOWN="1"
            shift
            ;;
        -t | --test)
            TEST=1
            shift
            ;;
        -c | --clean)
            docker container prune -f
            DOWN="1"
            shift
            ;;
        -n | --number)
            NUMBER="$2"
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        -4 | --ipv4)
            IPversion="4"
            shift
            ;;
        -b | --bridge)
            BRIDGE_NAME="$2"
            shift 2

            if ! sudo ovs-vsctl br-exists "$BRIDGE_NAME" ; then
                echo "Please provide a valid bridge name after -b or --bridge"
                exit 1
            fi
            ;;
        -B | --bridge-only)
            BRIDGE_ONLY="1"
            shift
            ;;
        *)
            echo >&2 "$UTIL: unknown command \"$1\" (use -h, --help for help)"
            exit 1
            ;;
    esac
done

TEST_NAME="br_test"
CONTROLLER_IP="10.42.0.1"

get_network_variables

if [[ "$NUMBER" -lt "1" ]] ; then
    echo >&2 "Please provide a valid number with -n or --number"
    exit 1
fi

BRIDGE="br${NUMBER}"

dumps_dir="/usr/share/dumps"

if [[ ! -d "$dumps_dir" ]] ; then
    mkdir -p "$dumps_dir"
fi

if [[ "$DOWN" = "1" ]] ; then 
    if [[ "$BRIDGE_NAME" != "" ]] ; then
        echo "down or -c cannot be used together with non default bridge name"
        exit 1
    fi

    if docker ps | grep "$TEST_NAME" > /dev/null ; then
        test_down
    fi

    border_router_down
    
    # Since no bridge name is set, assume default and delete
    bridge_down
fi

if [[ "$UP" = "1" ]] ; then

    if [[ "$BRIDGE_NAME" = ""  ]] ; then
        bridge_up
    else
        BRIDGE="$BRIDGE_NAME"
    fi

    if [[ "$BRIDGE_ONLY" -eq "0" ]] ; then
        if [[ "$TEST" -eq "1" ]] ; then
            test_up
        fi        
    
        border_router_up
    fi
fi
