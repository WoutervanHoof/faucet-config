#! /usr/bin/bash

set -euxo pipefail

# Required for otbr-docker
sudo modprobe ip6table_filter

# Adjust /dev/ttyACM* in compose file (a bit hacky, but oh well)
if [[ ! -f /dev/ttyACM0 ]] ; then
	dev_file=$(ls /dev/ttyACM* | head -n 1)
	sed -i -r -e "s#/dev/ttyACM.#${dev_file}#" docker-compose.yml
fi

docker container prune

docker-compose up
