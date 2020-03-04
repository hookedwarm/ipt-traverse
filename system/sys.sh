#!/bin/bash
declare -i ipv6
ipv6=0
declare -i rp
rp=0
declare -i forward
forward=0
declare -i martians
martians=0
declare -i icmp
icmp=0
declare -i args
args=$#
declare -i loop
loop=0
while (( $loop < $args )); do
	if [[ "$1" == "ipv6" ]]; then
		ipv6=1
	elif [[ "$1" == "rp" ]]; then
		rp=1
	elif [[ "$1" == "forward" ]]; then
		forward=1
	elif [[ "$1" == "martians" ]]; then
		martians=1
	elif [[ "$1" == "icmp" ]]; then
		icmp=1
	fi
	shift
	loop=$loop+1
done
if (( $ipv6 == 1 )); then
	sysctl -w net.ipv6.conf.all.disable_ipv6=0 1> /dev/null
else
	sysctl -w net.ipv6.conf.all.disable_ipv6=1 1> /dev/null
fi
if (( $rp == 1 )); then
	sysctl -w net.ipv4.conf.all.rp_filter=1 1> /dev/null
else
	sysctl -w net.ipv4.conf.all.rp_filter=0 1> /dev/null
fi
if (( $forward == 1 )); then
	sysctl -w net.ipv4.ip_forward=1 1> /dev/null
else
	sysctl -w net.ipv4.ip_forward=0 1> /dev/null
fi
if (( $martians == 1 )); then
	sysctl -w net.ipv4.conf.all.log_martians=1 1> /dev/null
	sysctl -w net.ipv4.conf.default.log_martians=1 1> /dev/null
else
	sysctl -w net.ipv4.conf.all.log_martians=0 1> /dev/null
	sysctl -w net.ipv4.conf.default.log_martians=0 1> /dev/null
fi
if (( $icmp == 1 )); then
	sysctl -w net.ipv4.icmp_echo_ignore_all=0 1> /dev/null
else
	sysctl -w net.ipv4.icmp_echo_ignore_all=1 1> /dev/null
fi
