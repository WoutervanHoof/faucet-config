#! /usr/bin/bash

set -exo pipefail

source ./network_layout.sh

container_name="server"

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

NET_KEY="00112233445566778899aabbccddeeff"
url="http://[${BORDER_ROUTER_IP}]:80"

if docker exec "$container_name" \
    curl -s -H "Content-Type: application/json" \
        "${url}/available_network" \
    | grep -q "\"error\":0"
then 
    docker exec "$container_name" \
        curl -s -H "Content-Type: application/json" \
            --request POST --data '{
                "credentialType":"networkKeyType",
                "networkKey":"'"${NET_KEY}"'",
                "prefix":"'"${OMR_PREFIX}"'",
                "defaultRoute":false,
                "index":0
            }' \
            "${url}/join_network"
else
    echo "Failed to get available networks"
    exit 1
fi

docker exec thread-br ot-ctl netdata publish route "$PREFIX_ROUTE" s high
