#!/bin/bash
iptables -A PREROUTING -t raw -m recent --set --name all
