#!/bin/bash
ext="$(cat devices/${1}/ext)"
./ipt_traverse.sh -t de/allo -r "-o $ext -m addrtype --dst-type LOCAL" -j "DROP"
