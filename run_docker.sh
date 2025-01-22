#! /usr/bin/bash

set -euxo pipefail

# Required for otbr-docker
sudo modprobe ip6table_filter

# Adjust /dev/ttyACM* in compose file
if [[ ! -f /dev/ttyACM0 ]] ; then
	dev_file=$(ls /dev/ttyACM* | head -n 1)
	sed -i -r -e "s#/dev/ttyACM.#${dev_file}#" docker-compose.yml
fi

docker-compose up


curl -H "Content-Type: application/json" --request POST --data '{"networkKey":"00112233445566778899aabbccddeeff","prefix":"fd11:22::","defaultRoute":true,"extPanId":"1111111122222222","panId":"0x1234","passphrase":"j01Nme","channel":15,"networkName":"OpenThreadDemo"}' http://localhost:8080/form_network
