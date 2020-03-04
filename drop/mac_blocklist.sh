#!/bin/bash
fil="devices/${1}/mac_blocklist"
for mac in $(cat "$fil"); do
	./ipt_traverse.sh -t de/alli -r "-m mac --mac-source $mac" -j "DROP"
done
