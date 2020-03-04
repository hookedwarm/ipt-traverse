#!/bin/bash
ext="$(cat devices/${1}/ext)"
ip1="$(cat devices/${2}/ip1)"
ip2="$(cat devices/${2}/ip2)"
iptables -t nat -I POSTROUTING -o $ext -s $ip1 -j SNAT --to-source $ip2 --random-fully
