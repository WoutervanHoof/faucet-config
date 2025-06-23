#! /bin/bash

set -euxo pipefail

pi_1=(./triple_1*)
pi_2=(./triple_2*)
pi_3=(./triple_3*)

for i in  "${!pi_1[@]}" ; do
    mergecap -w "triple_merged$(printf "%02d" $i).pcap" "${pi_1[$i]}" "${pi_2[$i]}" "${pi_3[$i]}"
done