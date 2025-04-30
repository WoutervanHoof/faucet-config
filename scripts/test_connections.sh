#!/bin/bash

docker exec thread-br ping -c 2 fd99:aaaa:bbbb:100::1
docker exec thread-br ping -c 2 fd99:aaaa:bbbb:200::2
docker exec thread-br ping -c 2 fd99:aaaa:bbbb:300::2

docker exec server ping -c 2 fd99:aaaa:bbbb:200::1
docker exec server ping -c 2 fd99:aaaa:bbbb:100::2
docker exec server ping -c 2 fd99:aaaa:bbbb:300::2

docker exec attacker ping -c 2 fd99:aaaa:bbbb:300::1
docker exec attacker ping -c 2 fd99:aaaa:bbbb:100::2
docker exec attacker ping -c 2 fd99:aaaa:bbbb:200::2
