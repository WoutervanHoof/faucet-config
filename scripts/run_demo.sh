#!/bin/bash

# Setup or tear down an OVS switch
# For testing purposes, add 2 docker containers
# Add the Border Router
# Add an internet connected interface

set -euxo pipefail

source "./network_layout.sh"

get_port_for_container_interface () {
    CONTAINER="$1"
    INTERFACE="$2"

    PORT=`sudo ovs-vsctl --data=bare --no-heading --columns=name find interface \
             external_ids:container_id="$CONTAINER"  \
             external_ids:container_iface="$INTERFACE"`
    if [ -z "$PORT" ]; then
        echo >&2 "Failed to find any attached port" \
                 "for CONTAINER=$CONTAINER and INTERFACE=$INTERFACE"
    fi
    echo "$PORT"
}

# Create bridge, set controller to "$CONTROLLER_IP" (TODO: allow setting IP)
bridge_up() {
    sudo ovs-vsctl --may-exist add-br "$BRIDGE" \
        -- set bridge "$BRIDGE" other-config:datapath-id=000000000000000"$NUMBER" \
        -- set bridge "$BRIDGE" other-config:disable-in-band=true \
        -- set bridge "$BRIDGE" fail_mode=secure \
        -- set-controller "$BRIDGE" "tcp:${CONTROLLER_IP}:6653" "tcp:${CONTROLLER_IP}:6654"
    
    sudo ip addr add "$BORDER_ROUTER_FAUCET_VIP" dev "$BRIDGE"
    sudo ip addr add "$SERVER_FAUCET_VIP" dev "$BRIDGE"
    sudo ip addr add "$ATTACKER_FAUCET_VIP" dev "$BRIDGE"
}


bridge_down() {
    sudo ip addr flush dev "$BRIDGE" || true
    sudo ovs-vsctl --if-exists del-br "$BRIDGE"
}

container_down() {
    sudo ovs-docker del-port "$BRIDGE" eth0 "$1" || true

    docker stop "$1" || true
    docker rm "$1" || true
}

attacker_up() {
    docker run -d --name "attacker" --net=none \
        --cap-add NET_ADMIN \
        --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
        --volume "$dumps_dir":"$dumps_dir" \
        nicolaka/netshoot /bin/bash -c "while true; do sleep 60; done"
    
    sudo ovs-docker add-port "$BRIDGE" eth0 "attacker" \
        --ipaddress="$ATTACKER_IP" \
        --gateway="$ATTACKER_FAUCET_VIP"

    PORT=`get_port_for_container_interface "attacker" "eth0"`
    sudo ovs-vsctl set interface "$PORT" ofport_request=3
}

attacker_down(){
    container_down "attacker"
}

server_up() {
    # We disable accept_ra and autoconf to block the borderrouters from spreading ips.
    # Those IPs mess up the preconfigured routes
    docker run -d --name="server" --net=none \
        --cap-add NET_ADMIN \
        --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
        --volume "$dumps_dir":"$dumps_dir" \
        nicolaka/netshoot /bin/bash -c "while true; do sleep 60; done"

    sudo ovs-docker add-port "$BRIDGE" eth0 "server" \
        --ipaddress="$SERVER_IP" \
        --gateway="$SERVER_FAUCET_VIP"
    
    PORT=`get_port_for_container_interface "server" "eth0"`
    sudo ovs-vsctl set interface "$PORT" ofport_request=2
}

server_down(){
    container_down "server"
}

border_router_up() {
    sudo modprobe ip6table_filter

    if [[ ! -e "/dev/ttyACM0" ]] ; then
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
	    wouter/otbr \
	    --radio-url "spinel+hdlc+uart:///dev/ttyACM0?uart-baudrate=115200&uart-flow-control" \
	    --mud-manager "$BORDER_ROUTER_FAUCET_VIP"

    sudo ovs-docker add-port "$BRIDGE" eth0 thread-br \
        --ipaddress="$BORDER_ROUTER_SUBNET" \
        --gateway="$BORDER_ROUTER_FAUCET_VIP"

    PORT=`get_port_for_container_interface "thread-br" "eth0"`
    sudo ovs-vsctl set interface "$PORT" ofport_request=1
}

border_router_down() {
    container_down "thread-br"
}

containers_up() {
    attacker_up
    server_up
    border_router_up
}

containers_down() {
    attacker_down
    server_down
    border_router_down
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
        -n, --number NUMBER Sets the number used to identify the border router. This sets both the IPv6 network submask as well as the datapath-id for OVS
        -c, --clean         Clean up a previous run of this script (in case smt went wrong)
        -b, --bridge BRIDGE An OVS bridge is already running, use it instead of creating a new one
        -B, --bridge-only   Only deploy the bridge, do not attach docker containers
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

UP=""
DOWN=""
NUMBER=""
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
        -b | --bridge)
            BRIDGE_NAME="$2"
            shift 2

            if ! sudo sudo ovs-vsctl br-exists "$BRIDGE_NAME" ; then
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

CONTROLLER_IP="10.42.0.1"

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

    containers_down
    
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
        containers_up
    fi
fi
