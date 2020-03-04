#!/bin/bash
log_arg=$1
./ipt_traverse.sh -t de/allnat_s -j "LOG" -l "$log_arg"
