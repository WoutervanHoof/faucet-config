#! /usr/bin/bash

set -eo pipefail

if [[ $# != 3 ]] ; then
    echo "usage: ./exp1.sh BR_NUMBER CHILD_IP ITERATIONS"
    exit 1
fi

NUMBER="$1"
CHILD_IP="$2"
iterations="$3"

timeout=0.5
server_success=0
attacker_success=0

source ~/faucet-config/scripts/network_layout.sh
get_network_layout
# This route gets added sometimes, I havent figured out yet how to prevent it
docker exec thread-br ip route del "$VLANS_ROUTE" dev wpan0 || true

echo ""
echo "Testing server..."
echo ""

for i in $(seq "$iterations") ; do 
    if docker exec server nc -v -z -w "$timeout" "$CHILD_IP" 23 ; then
        ((server_success+=1))
    fi
done

server_failures=$((iterations-server_success))

echo "#successful connections to the server through BR $NUMBER:   $server_success"
echo "#unsuccessful connections to the server through BR $NUMBER: $server_failures"

echo ""
echo "Testing attacker..."
echo ""

for i in $(seq "$iterations") ; do 
    if docker exec attacker nc -v -z -w 1 "$CHILD_IP" 23 ; then
        ((attacker_success+=1))
    fi
    sleep "$timeout"
done

attacker_failures=$((iterations-attacker_success))

echo "#successful connections to the attacker through BR $NUMBER:   $attacker_success"
echo "#unsuccessful connections to the attacker through BR $NUMBER: $attacker_failures"
