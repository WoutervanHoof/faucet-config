#! /bin/bash

set -eu

sudo ovs-appctl ofproto/trace br1 \
	'in_port=da57afa723e24_l,
	dl_src=b6:23:ed:84:be:8a,
	dl_dst=72:4e:db:83:c6:69,
	udp6,
	ipv6_dst=fd99:aaaa:bbbb:100::1,
	ipv6_src=fd71:666b:b2e1:bfd9:44ea:9c0a:d388:64ae,
	udp_dst=1234' \
	-generate


