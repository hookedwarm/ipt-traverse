#!/bin/bash
var_dir="devices/"
tcp_src_ports_list="tcp_src_ports_list"
tcp_dst_ports_list="tcp_dst_ports_list"
tcp_src_ports_shared_list="tcp_src_ports_shared_list"
tcp_dst_ports_shared_list="tcp_dst_ports_shared_list"
udp_src_ports_list="udp_src_ports_list"
udp_dst_ports_list="udp_dst_ports_list"
udp_src_ports_shared_list="udp_src_ports_shared_list"
udp_dst_ports_shared_list="udp_dst_ports_shared_list"
net_1="$(cat ${var_dir}net_1)"
net_2="$(cat ${var_dir}net_2)"
# macs
aintmac="00:11:22:33:44:55"
aextmac="00:11:22:33:44:55"
bintmac="AA:BB:CC:DD:EE:FF"
bextmac="FF:EE:DD:CC:BB:AA"
# shared device mac
smac=""
# router mac if you have a known mac address for packets returning to "b". if not, leave out the --mac-source option for those packets.
rmac="11:AA:22:BB:33:CC"
# interfaces
aint="aint"
aext="aint"
bint="bint"
bext="bext"
ause="a"
buse="b"
# is an interface being shared via "a"?
declare -i share
share=0
# ports
# firefox
# assume, by default, that we're always ok with tcp packets on port 443
tcp_src_ports="443"
tcp_dst_ports="443"
# for dns
udp_src_ports="53"
udp_dst_ports="53"
# https on shared device
tcp_src_ports_shared="443"
tcp_dst_ports_shared="443"
# dns shared
udp_src_ports_shared="53"
udp_dst_ports_shared="53"
declare -i args
arg=$#
declare -i loop
loop=0
# args to pass to the command line
# tcp port 80
declare -i http
http=0
# tcp port 21
declare -i ftp
ftp=0
# several ports
# this is an example of sharing a device through "a"
declare -i wii
wii=0
# transmission application - udp port 51413
declare -i tra
tra=0
while (( $loop < $arg )); do
	if [[ "$1" == "http" ]]; then
		if (( $share == 0 )); then
			http=1
		elif (( $share == 1 )); then
			if (( $http == 0 )); then
				http=2
			elif (( $http == 1 )); then
				http=3
			fi
		fi
	elif [[ "$1" == "ftp" ]]; then
		if (( $share == 0 )); then
			ftp=1
		elif (( $share == 1 )); then
			if (( $ftp == 0 )); then
				ftp=2
			elif (( $ftp == 1 )); then
				ftp=3
			fi
		fi
	elif [[ "$1" == "wii" ]]; then
		if (( $share == 0 )); then
			wii=1
		elif (( $share == 1 )); then
			if (( $wii == 0 )); then
				wii=2
			elif (( $wii == 1 )); then
				wii=3
			fi
		fi
	elif [[ "$1" == "tra" ]]; then
		if (( $share == 0 )); then
			tra=1
		elif (( $share == 1 )); then
			if (( $tra == 0 )); then
				tra=2
			elif (( $tra == 1 )); then
				tra=3
			fi
		fi
	elif [[ "$1" == "share" ]]; then
		share=1
	fi
	shift
	loop=$loop+1
done
echo "443" > ${var_dir}services/https
echo "443" >> ${var_dir}services/https
echo "" >> ${var_dir}services/https
echo "" >> ${var_dir}services/https
echo "" > ${var_dir}services/dns
echo "" >> ${var_dir}services/dns
echo "53" >> ${var_dir}services/dns
echo "53" >> ${var_dir}services/dns
if (( $share == 1 )); then
	echo "443" > ${var_dir}services_shared/https
	echo "443" >> ${var_dir}services_shared/https
	echo "" >> ${var_dir}services_shared/https
	echo "" >> ${var_dir}services_shared/https
	echo "" > ${var_dir}services_shared/dns
	echo "" >> ${var_dir}services_shared/dns
	echo "53" >> ${var_dir}services_shared/dns
	echo "53" >> ${var_dir}services_shared/dns
else
	echo "" > ${var_dir}services_shared/https
	echo "" >> ${var_dir}services_shared/https
	echo "" >> ${var_dir}services_shared/https
	echo "" >> ${var_dir}services_shared/https
	echo "" > ${var_dir}services_shared/dns
	echo "" >> ${var_dir}services_shared/dns
	echo "" >> ${var_dir}services_shared/dns
	echo "" >> ${var_dir}services_shared/dns
fi
if (( $http != 0 )); then
	if (( $http == 1 || $http == 3 )); then
		tcp_src_ports="$tcp_src_ports 80"
		tcp_dst_ports="$tcp_dst_ports 80"
		# source:
		echo "80" > ${var_dir}services/http
		# destination:
		echo "80" >> ${var_dir}services/http
		echo "" >> ${var_dir}services/http
		echo "" >> ${var_dir}services/http
	elif (( $http == 2 || $http == 3 )); then
		tcp_src_ports_shared="$tcp_src_ports_shared 80"
		tcp_dst_ports_shared="$tcp_dst_ports_shared 80"
		echo "80" > ${var_dir}services_shared/http
		echo "80" >> ${var_dir}services_shared/http
		echo "" >> ${var_dir}services_shared/http
		echo "" >> ${var_dir}services_shared/http
	fi
else
	echo "" > ${var_dir}services/http
	echo "" >> ${var_dir}services/http
	echo "" >> ${var_dir}services/http
	echo "" >> ${var_dir}services/http
	echo "" > ${var_dir}services_shared/http
	echo "" >> ${var_dir}services_shared/http
	echo "" >> ${var_dir}services_shared/http
	echo "" >> ${var_dir}services_shared/http
fi
if (( $ftp != 0 )); then
	if (( $ftp == 1 || $ftp == 3 )); then
		tcp_src_ports="$tcp_src_ports 21"
		tcp_dst_ports="$tcp_dst_ports 21"
		# source:
		echo "21" > ${var_dir}services/ftp
		# destination:
		echo "21" >> ${var_dir}services/ftp
		echo "" >> ${var_dir}services/ftp
		echo "" >> ${var_dir}services/ftp
	elif (( $ftp == 2 || $ftp == 3 )); then
		tcp_src_ports_shared="$tcp_src_ports 21"
		tcp_dst_ports_shared="$tcp_dst_ports 21"
		echo "21" > ${var_dir}services_shared/ftp
		echo "21" >> ${var_dir}services_shared/ftp
		echo "" >> ${var_dir}services_shared/ftp
		echo "" >> ${var_dir}services_shared/ftp
	fi
else
	echo "" > ${var_dir}services/ftp
	echo "" >> ${var_dir}services/ftp
	echo "" >> ${var_dir}services/ftp
	echo "" >> ${var_dir}services/ftp
	echo "" > ${var_dir}services_shared/ftp
	echo "" >> ${var_dir}services_shared/ftp
	echo "" >> ${var_dir}services_shared/ftp
	echo "" >> ${var_dir}services_shared/ftp
fi
if (( $wii != 0 )); then
	# (not actually wii ports at the moment)
	if (( $wii == 1 || $wii == 3 )); then
		tcp_src_ports="$tcp_src_ports 80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325"
		tcp_dst_ports="$tcp_dst_ports 80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325"
		udp_src_ports="$udp_src_ports 53 3478 3479 3659 17503 17504"
		udp_dst_ports="$udp_dst_ports 53 3478 3479 3659 17503 17504"
		# source:
		echo "80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325" > ${var_dir}services/wii
		# destination:
		echo "80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325" >> ${var_dir}services/wii
		echo "53 3478 3479 3659 17503 17504" >> ${var_dir}services/wii
		echo "53 3478 3479 3659 17503 17504" >> ${var_dir}services/wii
	elif (( $wii == 2 || $wii == 3 )); then
		tcp_src_ports_shared="$tcp_src_ports_shared 80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325"
		tcp_dst_ports_shared="$tcp_dst_ports_shared 80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325"
		udp_src_ports_shared="$udp_src_ports_shared 53 3478 3479 3659 17503 17504"
		udp_dst_ports_shared="$udp_dst_ports_shared 53 3478 3479 3659 17503 17504"
		echo "80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325" > ${var_dir}services_shared/wii
		echo "80 443 3478 3479 3480 9988 17503 17504 42120 42210 42230 44125 44225 44325" >> ${var_dir}services_shared/wii
		echo "53 3478 3479 3659 17503 17504" >> ${var_dir}services_shared/wii
		echo "53 3478 3479 3659 17503 17504" >> ${var_dir}services_shared/wii
	fi
	smac="12:34:56:78:9A:BC"
else
	echo "" > ${var_dir}services/wii
	echo "" >> ${var_dir}services/wii
	echo "" >> ${var_dir}services/wii
	echo "" >> ${var_dir}services/wii
	echo "" > ${var_dir}services_shared/wii
	echo "" >> ${var_dir}services_shared/wii
	echo "" >> ${var_dir}services_shared/wii
	echo "" >> ${var_dir}services_shared/wii
fi
if (( $tra != 0 )); then
	if (( $tra == 1 || $tra == 3 )); then
		udp_ports_src="$udp_ports_src 51413"
		udp_ports_dst="$udp_ports_dst 51413"
		echo "" > ${var_dir}services/tra
		echo "" >> ${var_dir}services/tra
		echo "51413" >> ${var_dir}services/tra
		echo "51413" >> ${var_dir}services/tra
	elif (( $tra == 2 || $tra == 3 )); then
		udp_ports_src_shared="$udp_ports_src 51413"
		udp_ports_dst_shared="$udp_ports_dst 51413"
		echo "" > ${var_dir}services_shared/tra
		echo "" >> ${var_dir}services_shared/tra
		echo "51413" >> ${var_dir}services_shared/tra
		echo "51413" >> ${var_dir}services_shared/tra
	fi
else
	echo "" > ${var_dir}services/tra
	echo "" >> ${var_dir}services/tra
	echo "" >> ${var_dir}services/tra
	echo "" >> ${var_dir}services/tra
	echo "" > ${var_dir}services_shared/tra
	echo "" >> ${var_dir}services_shared/tra
	echo "" >> ${var_dir}services_shared/tra
	echo "" >> ${var_dir}services_shared/tra
fi
# create random addresses
cd net_start/random
# 10
net_1=$(./random_addresses.sh 5 $net_1)
aip1=$(echo $net_1 | cut -f 1 -d " " -)
aip2=$(echo $net_1 | cut -f 2 -d " " -)
bip2=$(echo $net_1 | cut -f 3 -d " " -)
sip1=$(echo $net_1 | cut -f 4 -d " " -)
sip2=$(echo $net_1 | cut -f 5 -d " " -)
# 172
bip1=$(./random_address_ipv4.sh $net_2)
# create random macs
macs=$(./random_macs.sh 3 00:::::)
aints=$(echo $macs | cut -f 1 -d ' ')
aexts=$aints
bints=$(echo $macs | cut -f 2 -d ' ')
bexts=$(echo $macs | cut -f 3 -d ' ')
cd ../..
# write vars to files
echo $aintmac > ${var_dir}a/intmac
echo $aextmac > ${var_dir}a/extmac
echo $bintmac > ${var_dir}b/intmac
echo $bextmac > ${var_dir}b/extmac
echo $rmac > ${var_dir}r/mac
echo $aint > ${var_dir}a/int
echo $aext > ${var_dir}a/ext
echo $bint > ${var_dir}b/int
echo $bext > ${var_dir}b/ext
echo $aip1 > ${var_dir}a/ip1
echo $aip2 > ${var_dir}a/ip2
echo $bip1 > ${var_dir}b/ip1
echo $bip2 > ${var_dir}b/ip2
echo $sip1 > ${var_dir}s/ip1
echo $sip2 > ${var_dir}s/ip2
echo $aints > ${var_dir}a/ints
echo $aexts > ${var_dir}a/exts
echo $bints > ${var_dir}b/ints
echo $bexts > ${var_dir}b/exts
echo $smac > ${var_dir}s/mac
echo $share > ${var_dir}a/share
echo $ause > ${var_dir}/a/user
echo $buse > ${var_dir}/b/user
echo -n "" > ${var_dir}$tcp_src_ports_list
echo -n "" > ${var_dir}$tcp_dst_ports_list
echo -n "" > ${var_dir}$udp_src_ports_list
echo -n "" > ${var_dir}$udp_dst_ports_list
echo -n "" > ${var_dir}$tcp_src_ports_shared_list
echo -n "" > ${var_dir}$tcp_dst_ports_shared_list
echo -n "" > ${var_dir}$udp_src_ports_shared_list
echo -n "" > ${var_dir}$udp_dst_ports_shared_list
for port in $tcp_src_ports; do
	echo $port >> ${var_dir}$tcp_src_ports_list
done
for port in $tcp_dst_ports; do
	echo $port >> ${var_dir}$tcp_dst_ports_list
done
for port in $udp_src_ports; do
	echo $port >> ${var_dir}$udp_src_ports_list
done
for port in $udp_dst_ports; do
	echo $port >> ${var_dir}$udp_dst_ports_list
done

for port in $tcp_src_ports_shared; do
	echo $port >> ${var_dir}$tcp_src_ports_shared_list
done
for port in $tcp_dst_ports_shared; do
	echo $port >> ${var_dir}$tcp_dst_ports_shared_list
done
for port in $udp_src_ports_shared; do
	echo $port >> ${var_dir}$udp_src_ports_shared_list
done
for port in $udp_dst_ports_shared; do
	echo $port >> ${var_dir}$udp_dst_ports_shared_list
done
# general address blocklist - addresses that are blocked on all devices
echo "0.0.0.0" > ${var_dir}block
echo "255.255.255.255" >> ${var_dir}block
echo "10.255.255.255" >> ${var_dir}block
echo "172.31.255.255" >> ${var_dir}block
# a block:
# implement general blocklist
echo "$(cat ${var_dir}block)" > ${var_dir}a/blocklist
# machine-specific blocking
echo $bip1 >> ${var_dir}a/blocklist
echo $bip2 >> ${var_dir}a/blocklist
# b block:
echo "$(cat ${var_dir}block)" > $var_dir/b/blocklist
echo $aip1 >> ${var_dir}b/blocklist
echo $bip1 >> ${var_dir}b/blocklist
echo $bip2 >> ${var_dir}b/blocklist
echo $sip1 >> ${var_dir}b/blocklist
# general mac blocklist
echo -n "" > ${var_dir}mac_block
# block all real macs (cloned addresses will be used instead)
echo $aintmac >> ${var_dir}mac_block
echo $aextmac >> ${var_dir}mac_block
echo $bintmac >> ${var_dir}mac_block
echo $bextmac >> ${var_dir}mac_block
# specific mac blocklists
# a:
echo "$(cat ${var_dir}mac_block)" > ${var_dir}a/mac_blocklist
# "a" and the external interface on "b" should not communicate
echo $bexts >> ${var_dir}a/mac_blocklist
# "a" and a router should not directly communicate
echo $rmac >> ${var_dir}a/mac_blocklist
# b:
echo "$(cat ${var_dir}mac_block)" > ${var_dir}b/mac_blocklist
# "b" and the shared device should not directly communicate
echo $smac >> ${var_dir}b/mac_blocklist
