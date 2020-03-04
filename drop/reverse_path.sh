#!/bin/bash
iptables -t raw -A PREROUTING -m rpfilter --invert -j DROP
