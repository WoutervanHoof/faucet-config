#! /usr/bin/bash

set -eo pipefail

if [[ $# != 2 ]] ; then
    echo "usage: ./exp1.sh ITERATIONS TIMEOUT"
    exit 1
fi

iterations="$1"
timeout="$2"

# for ip in "fdfb:88ab:432d:1:df94:3d4e:b1a1:8468" "fdfb:88ab:432d:1:34b:6aa2:4fe2:8eff" ; do
for ip in "fdb0:67e9:41ac:1:817c:c22b:2fd8:834a" "fdb0:67e9:41ac:1:c064:72d6:88ed:7e4e" ; do
    successes=0

    echo ""
    echo "Testing $ip..."
    echo ""

    for i in $(seq "$iterations") ; do 
        echo -n "$i "
        if nc -z -w 1 "$ip" 23 ; then
            ((successes+=1))
        fi
        sleep "$timeout"
    done

    failures=$((iterations-successes))

    echo "#successes connections to the $ip :   $successes"
    echo "#failures connections to the $ip : $failures"

    # Test 
    echo ""
    ping -c "$iterations" "$ip" || true
    echo ""
done 
