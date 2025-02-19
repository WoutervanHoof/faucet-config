#! /usr/bin/bash

set -exo pipefail

IPversion="6"

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
