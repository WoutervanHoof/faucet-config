#! /usr/bin/bash

set -euxo pipefail

ORM_PREFIX="fd71:666b:b2e1:bfd9::"
MANAGEMENT_IP="10.42.0.10"
BR_IPV6="fdbe:8cb7:f64c:1::2"
passphrase="mystify-vantage-deduct"
NET_KEY="00112233445566778899aabbccddeeff"

curl "http://${MANAGEMENT_IP}:8080"
