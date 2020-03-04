#!/bin/bash
./ipt_traverse.sh -t de/in -j "DROP"
./ipt_traverse.sh -t de/out -j "DROP"
