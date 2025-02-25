#! /usr/bin/bash

set -exo pipefail

. ./network_layout.sh

IPversion="6"
container_name="br_test1"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n | --number)
            NUMBER="$2"
            shift 2
            ;;
        # -h | --help)
        #     usage
        #     exit 0
        #     ;;
        -4 | --ipv4)
            IPversion="4"
            shift
            ;;
        *)
            # Little ugly, but just catch unkown last argument as name            
            container_name="$1"
            shift
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

ORM_PREFIX="fd11:22:1:1::"

get_network_variables

url="http://[${BORDER_ROUTER_IP}]:80"

if [[ "$IPversion" = "4" ]] ; then
    BORDER_ROUTER_IP="10.43.${NUMBER}.2"
    url="http://${BORDER_ROUTER_IP}:80"
fi

set -u

if docker exec "$container_name" curl -s -H "Content-Type: application/json" --request GET "${url}/available_network" | grep -q "\"error\":0" ; then 
    docker exec "$container_name" curl -s -H "Content-Type: application/json" --request POST --data '{
        "credentialType":"networkKeyType",
        "networkKey":"'"${NET_KEY}"'",
        "prefix":"'"${ORM_PREFIX}"'",
        "defaultRoute":false,
        "index":0
    }' \
     "${url}/join_network"
else
    echo "Failed to get available networks"
    exit 1
fi

#docker exec "$container_name" ip -6 route add "${ORM_PREFIX}"/64 via "$BORDER_ROUTER_IP"
docker exec thread-br ot-ctl netdata publish route "$PREFIX_ROUTE" s high
# docker exec thread-br ip route add fdbe:ef11:11ca:2222::/64 dev eth0
# docker exec thread-br ot-ctl netdata publish fdbe:ef11:11ca:2222::/64 s high
