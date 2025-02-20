#! /usr/bin/bash

set -exo pipefail

NAME=$(basename "$0")
usage() {
    cat <<-EOF
        ${NAME}: Activates thread network in running docker container MultiMUD (TODO title).
        usage: ${NAME} [OPTION] -n NUMBER

        Options:
        -h, --help          display this help message.
        -n, --number        Sets the number used to identify the border router. This sets both the IPv6 network submask as well as the datapath-id for OVS
        -m, --name          Sets the name of the docker container from which the curl request is sent and which gets the route set
        -4, --ipv4          Use the ipv4 addresses instead of ipv6 addresses
EOF
}

IPversion="6"
# Default name, override with -m
container_name="br_test1"

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
        -4 | --ipv4)
            IPversion="4"
            shift
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

passphrase="mystify-vantage-deduct"
NET_KEY="00112233445566778899aabbccddeeff"

ORM_PREFIX="fd71:666b:b2e1:bfd9::"
BR_IP="fdbe:8cb7:f64c:abc${NUMBER}::2"
url="http://[${BR_IP}]:80"
EXTPAN="BEEF1111CAFE2222"

if [[ "$IPversion" = "4" ]] ; then
    BR_IP="10.43.${NUMBER}.2"
    url="http://${BR_IP}:80"
fi

while ! docker exec "$container_name" curl -sf "$url" > /dev/null ; do
    sleep 5
	echo "sleeping then trying again"
done

docker exec thread-br ot-ctl raoptions clear

docker exec "$container_name" curl -s -H "Content-Type: application/json" --request POST --data '{
    "networkKey":"'"${NET_KEY}"'",
    "prefix":"'"${ORM_PREFIX}"'",
    "defaultRoute":true,
    "extPanId":"'"${EXTPAN}"'",
    "panId":"0x1234",
    "passphrase":"'"${passphrase}"'",
    "channel":15,
    "networkName":"OpenThreadDemo"}' \
    "${url}/form_network"

docker exec "$container_name" ip -6 route add "${ORM_PREFIX}"/64 via "$BR_IP"
docker exec thread-br ot-ctl netdata publish route "fdbe:8cb7:f64c:abc${NUMBER}::/64" s high

# docker exec thread-br ip route add fdbe:ef11:11ca:2222::/64 dev eth0
# docker exec thread-br ot-ctl netdata publish route fdbe:ef11:11ca:2222::/64 s high

