#! /usr/bin/bash

set -euxo pipefail

ORM_PREFIX="fd71:666b:b2e1:bfd9::"
MANAGEMENT_IP="10.42.0.10"
passphrase="mystify-vantage-deduct"
NET_KEY="00112233445566778899aabbccddeeff"

# # Required for otbr-docker
# sudo modprobe ip6table_filter

# # Adjust /dev/ttyACM* in compose file (a bit hacky, but oh well)
# if [[ ! -f /dev/ttyACM0 ]] ; then
# 	dev_file=$(ls /dev/ttyACM* | head -n 1)
# 	sed -i -r -e "s#/dev/ttyACM.#${dev_file}#" docker-compose.yml
# fi

# docker-compose up

while true ; do
	sleep 5

	if  curl -H "Content-Type: application/json" --request POST --data '{
		"networkKey":"'"${NET_KEY}"'",	
		"prefix":"'"${ORM_PREFIX}"'",
		"defaultRoute":true,
		"extPanId":"1111111122222222",
		"panId":"0x1234",
		"passphrase":"'"${passphrase}"'",
		"channel":15,
		"networkName":"OpenThreadDemo"}' \
	"http://${MANAGEMENT_IP}:8080/form_network" | grep -q "success" ; then
		echo "Success"
	fi

	echo "sleeping then trying again"
done
