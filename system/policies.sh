#!/bin/bash

iptables -t raw -P PREROUTING DROP
iptables -t raw -P OUTPUT DROP

iptables -t mangle -P PREROUTING DROP
iptables -t mangle -P INPUT DROP
iptables -t mangle -P FORWARD DROP
iptables -t mangle -P OUTPUT DROP
iptables -t mangle -P POSTROUTING DROP

iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP

ip6tables -t raw -P PREROUTING DROP
ip6tables -t raw -P OUTPUT DROP

ip6tables -t mangle -P PREROUTING DROP
ip6tables -t mangle -P INPUT DROP
ip6tables -t mangle -P FORWARD DROP
ip6tables -t mangle -P OUTPUT DROP
ip6tables -t mangle -P POSTROUTING DROP

ip6tables -t filter -P INPUT DROP
ip6tables -t filter -P FORWARD DROP
ip6tables -t filter -P OUTPUT DROP
