#!/bin/bash
# list of log prefixes
log_arg="I4_ -l files/loglist_s"
dev_a="a"
dev_b="b"
dev_s="s"
dev_r="r"
# SYSTEM SCRIPTS
system/network_state.sh 0 # no tr
system/sys.sh rp # no tr
system/policies.sh # no tr
system/delete_and_flush.sh # no tr
# LOG scripts
log/list_all.sh # no tr
log/log_all.sh "$log_arg"
# DROP scripts
drop/blocklist.sh $dev_b
drop/mac_blocklist.sh $dev_b
drop/reverse_path.sh # no tr
drop/bad_packets.sh
drop/forward_only.sh
drop/drop_external_local_in.sh $dev_b
drop/drop_external_local_out.sh $dev_b
drop/drop_external_new.sh
# 'PASS' scripts
./new_chains.sh "TCP_DEVA_"
./new_chains.sh "UDP_DEVA_"
b/deva.sh $dev_b $dev_a $dev_r
./new_chains.sh "TCP_PORTS_"
./tcp_to_chains.sh "TCP_DEVA_" "TCP_PORTS_"
./new_chains.sh "UDP_PORTS_"
./udp_to_chains.sh "UDP_DEVA_" "UDP_PORTS_"
./ports.sh de/fw_s de/fw_s
./close.sh "TCP_PORTS_"
./close.sh "UDP_PORTS_"
if [[ "$(cat devices/a/share)" != "0" ]]; then
	./new_chains.sh "TCP_DEVS_"
	./new_chains.sh "UDP_DEVS_"
	b/devs.sh $dev_b $dev_s $dev_a $dev_r
	./new_chains.sh "TCP_SHARED_PORTS_"
	./tcp_to_chains.sh "TCP_DEVS_" "TCP_SHARED_PORTS_"
	./new_chains.sh "UDP_SHARED_PORTS_"
	./udp_to_chains.sh "UDP_DEVS_" "UDP_SHARED_PORTS_"
	./ports_share.sh de/fw_s de/fw_s
	# close port list
	./close.sh "TCP_SHARED_PORTS_"
	./close.sh "UDP_SHARED_PORTS_"
fi
./new_chains.sh "DNS_"
services/dns.sh gw/fwfw gw
services/dns.sh gw/allall_s gw_s
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVA_" "UDP_DEVA_" "DNS_" devices/services/dns
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "DNS_" devices/services_shared/dns
./new_chains.sh "HTTPS_"
services/accept.sh "HTTPS_"
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVA_" "UDP_DEVA_" "HTTPS_" devices/services/https
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "HTTPS_" devices/services_shared/https
./new_chains.sh "HTTP_"
services/accept.sh "HTTP_"
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVA_" "UDP_DEVA_" "HTTP_" devices/services/http
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "HTTP_" devices/services_shared/http
./new_chains.sh "FTP_"
services/accept.sh "FTP_"
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVA_" "UDP_DEVA_" "FTP_" devices/services/ftp
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "FTP_" devices/services_shared/ftp
./new_chains.sh "WII_"
services/accept.sh "WII_"
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "WII_" devices/services_shared/wii
./new_chains.sh "TRA_"
services/accept.sh "TRA_"
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVA_" "UDP_DEVA_" "TRA_" devices/services/tra
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "TRA_" devices/services_shared/tra
# close DEVA and DEVS chains
./close.sh "TCP_DEVA_"
./close.sh "UDP_DEVA_"
./close.sh "TCP_DEVS_"
./close.sh "UDP_DEVS_"
# drop everything
drop/drop_all.sh
# NAT
b/nat.sh $dev_b # no tr
# SYSTEM
system/sys.sh forward # no tr
system/network_state.sh 1 # no tr
b/network_manager_external.sh $dev_b "Ethernet connection 1" 1> /dev/null # no tr
b/network_manager_internal.sh $dev_b 1> /dev/null # no tr
