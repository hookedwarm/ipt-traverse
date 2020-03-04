#!/bin/bash
chain="$1"
target="$2"
./ipt_traverse.sh -t de/all_s -A "$chain" -r "-p udp" -j "$target -l files/chains"
