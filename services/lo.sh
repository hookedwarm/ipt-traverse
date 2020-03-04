#!/bin/bash
./ipt_traverse.sh -t de/io -r "-i lo" -s -j "ACCEPT" -ll "AC_ -l files/loglist"
