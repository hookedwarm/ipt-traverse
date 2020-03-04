#!/bin/bash
int="$(cat devices/${1}/int)"
ext="$(cat devices/${1}/ext)"
# natted ip of dev a
ip1="$(cat devices/${2}/ip2)"
# mac source of a
mac="$(cat devices/${2}/exts)"
# mac source of r
mar="$(cat devices/${3}/mac)"
./ipt_traverse.sh -t gw/fwfw -r "-p tcp -i $int -o $ext" -s gw -r "-s $ip1 -m mac --mac-source $mac" -p de/fw -r "-m mac --mac-source $mar -m conntrack --ctstate ESTABLISHED,RELATED" -p gw/fwrep -r "-d $ip1" -p gw/fwposnatrep -j "TCP_DEVA_ -l files/chains"
./ipt_traverse.sh -t gw/fwfw -r "-p udp -i $int -o $ext" -s gw -r "-s $ip1 -m mac --mac-source $mac" -p de/fw -r "-m mac --mac-source $mar -m conntrack --ctstate ESTABLISHED,RELATED" -p gw/fwrep -r "-d $ip1" -p gw/fwposnatrep -j "UDP_DEVA_ -l files/chains"
