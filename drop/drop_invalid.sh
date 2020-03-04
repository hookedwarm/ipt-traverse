#!/bin/bash
ext="$(cat devices/${1}/ext)"
iptables -t filter -A INPUT -i $ext -m conntrack --ctstate INVALID -j DROP
