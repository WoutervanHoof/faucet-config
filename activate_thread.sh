#! /usr/bin/bash

set -exo pipefail

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

ORM_PREFIX="fd71:666b:b2e1:bfd9::"
BR_IP="fdbe:8cb7:f64c:${NUMBER}::2"
url="http://[${BR_IP}]:80/form_network"

if [[ "$IPversion" = "4" ]] ; then
    BR_IP="10.43.${NUMBER}.2"
    url="http://${BR_IP}:80/form_network"
fi

while ! docker exec "$container_name" curl -sf "http://[${BR_IP}]:80" > /dev/null ; do
    sleep 5
	echo "sleeping then trying again"
done

docker exec "$container_name" curl -s -H "Content-Type: application/json" --request POST --data '{
    "networkKey":"'"${NET_KEY}"'",	
    "prefix":"'"${ORM_PREFIX}"'",
    "defaultRoute":true,
    "extPanId":"1111111122222222",
    "panId":"0x1234",
    "passphrase":"'"${passphrase}"'",
    "channel":15,
    "networkName":"OpenThreadDemo"}' \
    "$url"

docker exec "$container_name" ip route -6 add "${ORM_PREFIX}"/64 via "$BR_IP"
