#!/bin/bash

source ./network_layout.sh

docker exec thread-br ping -c 2 "$BORDER_ROUTER_FAUCET_VIP"
docker exec thread-br ping -c 2 "$SERVER_IP"
docker exec thread-br ping -c 2 "$ATTACKER_IP"

docker exec server ping -c 2 "$SERVER_FAUCET_VIP"
docker exec server ping -c 2 "$BORDER_ROUTER_IP"
docker exec server ping -c 2 "$ATTACKER_IP"

docker exec attacker ping -c 2 "$ATTACKER_FAUCET_VIP"
docker exec attacker ping -c 2 "$BORDER_ROUTER_IP"
docker exec attacker ping -c 2 "$SERVER_IP"
