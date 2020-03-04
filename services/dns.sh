#!/bin/bash
loglist="files/loglist"
./ipt_traverse.sh -t "$1" -A "DNS_" -r "-s 208.67.222.222" -s "$2" -j "ACCEPT" -ll "AC_ -l $loglist"
./ipt_traverse.sh -t "$1" -A "DNS_" -r "-s 208.67.220.220" -s "$2" -j "ACCEPT" -ll "AC_ -l $loglist"
./ipt_traverse.sh -t de/all_s -A "DNS_" -j "DROP"
