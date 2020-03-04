#!/bin/bash
iptables -F -t mangle
iptables -F -t nat
iptables -F -t filter
iptables -F -t raw
iptables -F
iptables -X -t mangle
iptables -X -t nat
iptables -X -t filter
iptables -X -t raw
iptables -X 

ip6tables -F -t mangle
ip6tables -F -t nat
ip6tables -F -t filter
ip6tables -F -t raw
ip6tables -F
ip6tables -X -t mangle
ip6tables -X -t nat
ip6tables -X -t filter
ip6tables -X -t raw
ip6tables -X
