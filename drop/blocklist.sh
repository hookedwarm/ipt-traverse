#!/bin/bash
fil="devices/${1}/blocklist"
for add in $(cat "$fil"); do
	./ipt_traverse.sh -t de/alli -r "-s $add" -j "DROP"
	./ipt_traverse.sh -t de/allo -r "-d $add" -j "DROP"
done
