#! /usr/bin/bash

set -exo pipefail

source ./network_layout.sh

NAME=$(basename "$0")
usage() {
    cat <<-EOF
        ${NAME}: Activates thread network in running docker container MultiMUD (TODO title).
        usage: ${NAME} [OPTION] -n NUMBER

        Options:
        -h, --help          display this help message.
        -n, --number        Sets the number used to identify the border router. This sets both the IPv6 network submask as well as the datapath-id for OVS
        -m, --name          Sets the name of the docker container from which the curl request is sent and which gets the route set
EOF
}

# Default name, override with -m
container_name="server"

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
        -m | --name)
            container_name="$2"
            shift 2
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

set -u

get_network_layout

passphrase="mystify-vantage-deduct"
NET_KEY="00112233445566778899aabbccddeeff"

url="http://[${BORDER_ROUTER_IP}]:80"
EXTPAN="BEEF1111CAFE2222"

while ! docker exec "$container_name" curl -sf "$url" > /dev/null ; do
	echo "sleeping then trying again"
    sleep 5
done

# docker exec thread-br ot-ctl br raoptions clear

docker exec "$container_name" curl -s \
    -H "Content-Type: application/json" \
    --request POST --data '{
        "networkKey":"'"${NET_KEY}"'",
        "prefix":"'"${OMR_PREFIX}"'",
        "defaultRoute":true,
        "extPanId":"'"${EXTPAN}"'",
        "panId":"0x1234",
        "passphrase":"'"${passphrase}"'",
        "channel":15,
        "networkName":"OpenThreadDemo"}' \
    "${url}/form_network"


docker exec thread-br ot-ctl netdata publish route "$VLANS_ROUTE" s high
