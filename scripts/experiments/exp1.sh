#! /usr/bin/bash

set -eo pipefail

if [[ $# != 3 ]] ; then
    echo "usage: ./exp1.sh BR_NUMBER CHILD_IP ITERATIONS"
    exit 1
fi

number="$1"
CHILD_IP="$2"
iterations="$3"

timeout=0.5
server_success=0
attacker_success=0

echo ""
echo "Testing server..."
echo ""

for i in $(seq "$iterations") ; do 
    if docker exec server nc -z -w 1 "$CHILD_IP" 23 ; then
        ((server_success+=1))
    fi
    sleep "$timeout"
done

server_failures=$((iterations-server_success))

echo "Number of successful connections to the server:   $server_success"
echo "Number of unsuccessful connections to the server: $server_failures"

echo ""
echo "Testing attacker..."
echo ""

for i in $(seq "$iterations") ; do 
    if docker exec attacker nc -z -w 1 "$CHILD_IP" 23 ; then
        ((attacker_success+=1))
    fi
    sleep "$timeout"
done

attacker_failures=$((iterations-attacker_success))

echo "Number of successful connections to the attacker:   $attacker_success"
echo "Number of unsuccessful connections to the attacker: $attacker_failures"
