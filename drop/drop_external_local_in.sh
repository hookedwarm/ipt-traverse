#!/bin/bash
ext="$(cat devices/${1}/ext)"
./ipt_traverse.sh -t de/alli -r "-i $ext -m addrtype --src-type LOCAL" -j "DROP"
