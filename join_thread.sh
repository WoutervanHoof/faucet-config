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
BR_IP="fdbe:8cb7:f64c:abc${NUMBER}::2"
url="http://[${BR_IP}]:80"

if [[ "$IPversion" = "4" ]] ; then
    BR_IP="10.43.${NUMBER}.2"
    url="http://${BR_IP}:80"
fi

set -u

if docker exec "$container_name" curl -s -H "Content-Type: application/json" --request GET "${url}/available_network" | grep -q "\"error\":0" ; then 
    docker exec "$container_name" curl -s -H "Content-Type: application/json" --request POST --data '{
        "credentialType":"networkKeyType",
        "networkKey":"00112233445566778899aabbccddeeff",
        "prefix":"fd11:22:1:1",
        "defaultRoute":false,
        "index":0
    }' \
     "${url}/join_network"
else
    echo "Failed to get available networks"
    exit 1
fi

docker exec thread_br ot-ctl netdata publish route fdbe:8cb7:f64c:abc${NUMBER}:: s high
