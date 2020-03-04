#!/bin/bash
loglist="files/loglist"
./ipt_traverse.sh -t de/all_s -A "$1" -j "ACCEPT" -ll "AC_ -l $loglist"
./ipt_traverse.sh -t de/all_s -A "$1" -j "DROP"
