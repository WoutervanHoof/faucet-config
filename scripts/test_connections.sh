#!/bin/bash

source ./network_layout.sh

NAME=$(basename "$0")
usage() {
    cat <<-EOF
        ${NAME}: Test network connections of my demo
        usage: ${NAME} [OPTION] -n NUMBER

        Options:
        -h, --help          display this help message.
        -n, --number        Sets the number used to identify the border router. This sets both the IPv6 network submask as well as the datapath-id for OVS
EOF
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n | --number)
            NUMBER="$2"
            shift 2
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

if [[ "$NUMBER" -lt "1" ]] ; then
    echo >&2 "Please provide a valid number with -n or --number"
    exit 1
fi

get_network_layout

docker exec thread-br ping -c 2 "$BORDER_ROUTER_FAUCET_VIP"
docker exec thread-br ping -c 2 "$SERVER_IP"
docker exec thread-br ping -c 2 "$ATTACKER_IP"

docker exec server ping -c 2 "$SERVER_FAUCET_VIP"
docker exec server ping -c 2 "$BORDER_ROUTER_IP"
docker exec server ping -c 2 "$ATTACKER_IP"

docker exec attacker ping -c 2 "$ATTACKER_FAUCET_VIP"
docker exec attacker ping -c 2 "$BORDER_ROUTER_IP"
docker exec attacker ping -c 2 "$SERVER_IP"
