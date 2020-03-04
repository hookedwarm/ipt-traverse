#!/bin/bash
ext="$(cat devices/${1}/ext)"
./ipt_traverse.sh -t de/alli -r "-i $ext -m state --state NEW" -j "DROP"
./ipt_traverse.sh -t de/alli -r "-i $ext -m conntrack --ctstate NEW" -j "DROP"
./ipt_traverse.sh -t de/alli -r "-i $ext -p tcp --syn" -j "DROP"
