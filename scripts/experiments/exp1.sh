#! /usr/bin/bash

set -eo pipefail

if [[ $# != 4 ]] ; then
    echo "usage: ./exp1.sh BR_NUMBER CHILD_IP ITERATIONS TIMEOUT"
    exit 1
fi

NUMBER="$1"
CHILD_IP="$2"
iterations="$3"
timeout="$4"

source ~/faucet-config/scripts/network_layout.sh
get_network_layout
# This route gets added sometimes, I havent figured out yet how to prevent it
docker exec thread-br ip route del "$VLANS_ROUTE" dev wpan0 || true

for role in "server" "attacker" ; do
    successes=0

    echo ""
    echo "Testing $role..."
    echo ""

    for i in $(seq "$iterations") ; do 
        echo -n "$i "
        if docker exec "$role" nc -v -z -w 1 "$CHILD_IP" 23 ; then
            ((successes+=1))
        fi
        sleep "$timeout"
    done

    failures=$((iterations-successes))

    echo "#successes connections to the $role through BR $NUMBER:   $successes"
    echo "#failures connections to the $role through BR $NUMBER: $failures"
done 
