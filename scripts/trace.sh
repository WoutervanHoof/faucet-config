#! /bin/bash

set -eu

sudo ovs-appctl ofproto/trace br1 \
	'in_port=,
	dl_src=b6:23:ed:84:be:8a,
	dl_dst=72:4e:db:83:c6:69,
	udp6,
	ipv6_dst=fd99:aaaa:bbbb:200::2,
	ipv6_src=fd71:666b:b2e1:bfd9:632a:c97d:5fc5:9d11,
	udp_dst=5001' \
	-generate


