#! /usr/bin/bash

set -exo pipefail

if [[ -z "$1" ]] ; then 
    echo "Please provide the container name"
    exit 1
fi

set -u

container_name="$1"
ORM_PREFIX="fd71:666b:b2e1:bfd9::"
MANAGEMENT_IP="10.42.0.10"
BR_IPV6="fdbe:8cb7:f64c:1::2"
passphrase="mystify-vantage-deduct"
NET_KEY="00112233445566778899aabbccddeeff"

while ! docker exec "$container_name" curl -sf "http://[${BR_IPV6}]:80" > /dev/null ; do
    # Test with a random string that is outputted when a webpage is returned

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
    "http://[${BR_IPV6}]:80/form_network"

docker exec "$container_name" ip -6 route add "${ORM_PREFIX}"/64 via "$BR_IPV6"
