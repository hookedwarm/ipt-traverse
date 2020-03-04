#!/bin/bash
var_dir="devices/"
tcp_src_ports_shared_list="tcp_src_ports_shared_list"
tcp_dst_ports_shared_list="tcp_dst_ports_shared_list"
udp_src_ports_shared_list="udp_src_ports_shared_list"
udp_dst_ports_shared_list="udp_dst_ports_shared_list"
chain_arg="TCP_SHARED_PORTS_"
for port in $(cat ${var_dir}$tcp_src_ports_shared_list); do
	./ipt_traverse.sh -t "$1" -A "$chain_arg" -r "-p tcp --sport $port" -j "RETURN"
done
for port in $(cat ${var_dir}$tcp_dst_ports_shared_list); do
	./ipt_traverse.sh -t "$2" -A "$chain_arg" -r "-p tcp --dport $port" -j "RETURN"
done
chain_arg="UDP_SHARED_PORTS_"
for port in $(cat ${var_dir}$udp_src_ports_shared_list); do
	./ipt_traverse.sh -t "$1" -A "$chain_arg" -r "-p udp --sport $port" -j "RETURN"
done
for port in $(cat ${var_dir}$udp_dst_ports_shared_list); do
	./ipt_traverse.sh -t "$2" -A "$chain_arg" -r "-p udp --dport $port" -j "RETURN"
done
