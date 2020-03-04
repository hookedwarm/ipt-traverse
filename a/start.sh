#!/bin/bash
# list of log prefixes
log_arg="I4_ -l files/loglist_s"
dev_a="a"
dev_b="b"
dev_s="s"
# SYSTEM SCRIPTS
system/network_state.sh 0
system/sys.sh rp
system/policies.sh
system/delete_and_flush.sh
# LOG scripts
log/list_all.sh
log/log_all.sh "$log_arg"
# DROP scripts
drop/blocklist.sh $dev_a
drop/mac_blocklist.sh $dev_a
drop/reverse_path.sh
drop/bad_packets.sh
# if not sharing, close forward and disable in sy
if [[ "$(cat devices/a/share)" == "0" ]]; then
	drop/forward_close.sh
	drop/drop_external_local_in.sh $dev_a
elif [[ "$(cat devices/a/share)" != "0" ]]; then
	drop/forward_only.sh
fi
drop/drop_external_local_out.sh $dev_a
drop/drop_invalid.sh $dev_a
# LOOPBACK
services/lo.sh
# 'PASS' scripts
./new_chains.sh "TCP_DEVA_"
./new_chains.sh "UDP_DEVA_"
a/deva.sh $dev_a $dev_b
./new_chains.sh "TCP_PORTS_"
./new_chains.sh "UDP_PORTS_"
./tcp_to_chains.sh "TCP_DEVA_" "TCP_PORTS_"
./udp_to_chains.sh "UDP_DEVA_" "UDP_PORTS_"
./ports.sh de/alli de/allo
# close port list
./close.sh "TCP_PORTS_"
./close.sh "UDP_PORTS_"
if [[ "$(cat devices/a/share)" != "0" ]]; then
	./new_chains.sh "TCP_DEVS_"
	./new_chains.sh "UDP_DEVS_"
	a/devs.sh $dev_a $dev_s $dev_b
	./new_chains.sh "TCP_SHARED_PORTS_"
	./new_chains.sh "UDP_SHARED_PORTS_"
	./tcp_to_chains.sh "TCP_DEVS_" "TCP_SHARED_PORTS_"
	./udp_to_chains.sh "UDP_DEVS_" "UDP_SHARED_PORTS_"
	./ports_share.sh de/alli de/allo
	./close.sh "TCP_SHARED_PORTS_"
	./close.sh "UDP_SHARED_PORTS_"
	drop/drop_external_local_in.sh $dev_a
fi
# ACCEPT scripts
./new_chains.sh "DNS_"
services/dns.sh gw/allall_s gw_s
services/ports_to_chains.sh de/i de/o "TCP_DEVA_" "UDP_DEVA_" "DNS_" devices/services/dns
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "DNS_" devices/services_shared/dns
./new_chains.sh "HTTPS_"
services/accept.sh "HTTPS_"
services/ports_to_chains.sh de/i de/o "TCP_DEVA_" "UDP_DEVA_" "HTTPS_" devices/services/https
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "HTTPS_" devices/services_shared/https
./new_chains.sh "HTTP_"
services/accept.sh "HTTP_"
services/ports_to_chains.sh de/i de/o "TCP_DEVA_" "UDP_DEVA_" "HTTP_" devices/services/http
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "HTTP_" devices/services_shared/http
./new_chains.sh "FTP_"
services/accept.sh "FTP_"
services/ports_to_chains.sh de/i de/o "TCP_DEVA_" "UDP_DEVA_" "FTP_" devices/services/ftp
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "FTP_" devices/services_shared/ftp
./new_chains.sh "WII_"
services/accept.sh "WII_"
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "WII_" devices/services_shared/wii
./new_chains.sh "TRA_"
services/accept.sh "TRA_"
services/ports_to_chains.sh de/i de/o "TCP_DEVA_" "UDP_DEVA_" "TRA_" devices/services/tra
services/ports_to_chains.sh de/fw_s de/fw_s "TCP_DEVS_" "UDP_DEVS_" "TRA_" devices/services_shared/tra
# close DEVA and DEVS chains
./close.sh "TCP_DEVA_"
./close.sh "UDP_DEVA_"
./close.sh "TCP_DEVS_"
./close.sh "UDP_DEVS_"
# drop everything
drop/drop_all.sh
# NAT
a/nat.sh $dev_a $dev_a
if [[ "$(cat devices/a/share)" == "1" ]]; then
	a/nat.sh $dev_a $dev_s
fi
# SYSTEM
if [[ "$(cat devices/a/share)" == "0" ]]; then
	system/sys.sh rp ipv6
else
	system/sys.sh rp forward ipv6
fi
system/network_state.sh 1
a/network_manager.sh $dev_a $dev_b 1> /dev/null
