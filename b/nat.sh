#!/bin/bash
ext="$(cat devices/${1}/ext)"
iptables -t nat -A POSTROUTING -o $ext -j MASQUERADE --random
