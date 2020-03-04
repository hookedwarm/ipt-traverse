#!/bin/bash
./ipt_traverse.sh -t de/all_s -A "$1" -j "DROP"
