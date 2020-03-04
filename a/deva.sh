#!/bin/bash
int="$(cat devices/${1}/int)"
ext="$(cat devices/${1}/ext)"
ip1="$(cat devices/${1}/ip1)"
ip2="$(cat devices/${1}/ip2)"
mar="$(cat devices/${2}/ints)"
./ipt_traverse.sh -t de/io -r "-p tcp -i $int -o $ext" -r "-s $ip1" -p de/o -r "-d $ip2" -p de/pre -r "-d $ip1" -p de/in -r "-m mac --mac-source $mar -m conntrack --ctstate ESTABLISHED,RELATED" -p de/i -j "TCP_DEVA_ -l files/chains"
./ipt_traverse.sh -t de/io -r "-p udp -i $int -o $ext" -r "-s $ip1" -p de/o -r "-d $ip2" -p de/pre -r "-d $ip1" -p de/in -r "-m mac --mac-source $mar -m conntrack --ctstate ESTABLISHED,RELATED" -p de/i -j "UDP_DEVA_ -l files/chains"
