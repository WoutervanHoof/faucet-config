#! /usr/bin/bash

base_file="faucet_base.yaml"

if [[ $# == 1 ]] ; then
    base_file="$1"
fi

set -euo pipefail

BASE="/home/wouter/projects/thesis/faucet-config/"

pushd "$BASE/volumes/etc/faucet/"

cp "$base_file"  faucet.yaml

docker exec faucet-config-mud-manager-1 rm /var/mudfiles/3000_mud.json || true

# pop $BASE/volumes/etch/fautcet/
popd 
