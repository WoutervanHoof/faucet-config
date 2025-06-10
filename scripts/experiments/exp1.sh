#! /usr/bin/bash

set -exo pipefail

source ./network_layout.sh

iterations=1000
server_success=0
attacker_success=0

for i in {1.."$iterations"} ; do 
    if docker exec server nc -z -w 1 "$CHILD_IP" ; then
        ((server_success=server_success+1))
    fi
done
((server_failures = iterations - server_success))


echo "Number of successful connections to the server:   $server_success"
echo "Number of unsuccessful connections to the server: $server_failures"

for i in {1.."$iterations"} ; do 
    if docker exec attacker nc -z -w 1 "$CHILD_IP" ; then
        ((attacker_success=attacker_success+1))
    fi
done

((attacker_failures=iterations-attacker_success))


echo "Number of successful connections to the attacker:   $attacker_success"
echo "Number of unsuccessful connections to the attacker: $attacker_failures"