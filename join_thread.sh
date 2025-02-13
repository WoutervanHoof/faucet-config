#! /usr/bin/bash

set -exo pipefail

if [[ -z "$1" ]] ; then 
    echo "Please provide the container name"
    exit 1
fi

if [[ -z "$2" ]] ; then 
    echo "Please provide the border router number"
    exit 1
fi

set -u

container_name="$1"
NUMBER="$2"
ORM_PREFIX="fd71:666b:b2e1:bfd9::"
MANAGEMENT_IP="10.42.0.10"
BR_IPV6="fdbe:8cb7:f64c:${NUMBER}::2"
passphrase="mystify-vantage-deduct"
NET_KEY="00112233445566778899aabbccddeeff"

if docker exec "$container_name" curl -s -H "Content-Type: application/json" --request GET "http://[${BR_IPV6}]:80/available_network" | grep -q "\"error\":0" ; then 
    docker exec "$container_name" curl -s -H "Content-Type: application/json" --request POST --data '{
        "credentialType":"networkKeyType",
        "networkKey":"00112233445566778899aabbccddeeff",
        "prefix":"fd11:22::",
        "defaultRoute":false,
        "index":0
    }' \
     "http://[${BR_IPV6}]:80/join_network"
else
    echo "Failed to get available networks"
    exit 1
fi
