#!/bin/bash
int="$(cat devices/${1}/int)"
ext="$(cat devices/${1}/ext)"
ip1="$(cat devices/${2}/ip1)"
ip2="$(cat devices/${2}/ip2)"
mac="$(cat devices/${2}/mac)"
mar="$(cat devices/${3}/ints)"
./ipt_traverse.sh -t gw/fwfw -r "-p tcp -i $int -o $ext" -r "-m mac --mac-source $mac" -p de/alli -r "-s $ip1" -p de/fw -r "-d $ip2" -p gw/prerep -r "-d $ip1" -p gw/fwposnatrep -r "-m mac --mac-source $mar" -p gw/allirep -r "-m conntrack --ctstate ESTABLISHED,RELATED" -p gw/fwrep -j "TCP_FW_ -l files/chains"
./ipt_traverse.sh -t gw/fwfw -r "-p udp -i $int -o $ext" -r "-m mac --mac-source $mac" -p de/alli -r "-s $ip1" -p de/fw -r "-d $ip2" -p gw/prerep -r "-d $ip1" -p gw/fwposnatrep -r "-m mac --mac-source $mar" -p gw/allirep -r "-m conntrack --ctstate ESTABLISHED,RELATED" -p gw/fwrep -j "UDP_FW_ -l files/chains"
