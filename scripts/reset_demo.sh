#! /usr/bin/bash

set -euo pipefail

BASE="/home/wouter/projects/thesis/faucet-config/"

pushd "$BASE/volumes/etc/faucet/"

cp faucet_base.yaml faucet.yaml

docker exec faucet-config-mud-manager-1 rm /var/mudfiles/3000_mud.json || true

# pop $BASE/volumes/etch/fautcet/
popd 
