#!/bin/bash
./ipt_traverse.sh -t de/alli -r "-m mac --mac-source 00:00:00:00:00:00" -j "DROP"
./ipt_traverse.sh -t de/alli -r "-m mac --mac-source FF:FF:FF:FF:FF:FF" -j "DROP"
./ipt_traverse.sh -t de/alli -r "-s 0.0.0.0" -j "DROP"
./ipt_traverse.sh -t de/allo -r "-d 0.0.0.0" -j "DROP"
./ipt_traverse.sh -t de/all_s -r "-p tcp --tcp-flags ALL ALL" -j "DROP"
./ipt_traverse.sh -t de/all_s -r "-p tcp --tcp-flags ALL NONE" -j "DROP"
types="UNSPEC BROADCAST ANYCAST MULTICAST BLACKHOLE UNREACHABLE PROHIBIT"
for type in $types; do
	./ipt_traverse.sh -t de/alli -r "-m addrtype --src-type $type" -j "DROP"
	./ipt_traverse.sh -t de/allo -r "-m addrtype --dst-type $type" -j "DROP"
done
