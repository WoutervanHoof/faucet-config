#! /usr/bin/bash

set -euxo pipefail

# Required for otbr-docker
sudo modprobe ip6table_filter

if [ ! -f /dev/ttyACM0 ] ; then 
	echo "File /dev/ttyACM0 does not exist"
	exit 1
fi

docker container prune

docker-compose up
