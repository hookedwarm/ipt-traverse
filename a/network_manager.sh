#!/bin/bash
if="$(cat devices/${1}/ext)"
mc="$(cat devices/${1}/extmac)"
ms="$(cat devices/${1}/exts)"
# TODO: mask should be passed
ip="$(cat devices/${1}/ip1)/8"
us="$(cat devices/${1}/user)"
gw="$(cat devices/${2}/ip1)"
if [[ "$8" == "" ]]; then
	name="Wired connection 1"
else
	name="$7"
fi
nmcli radio all off
nmcli connection delete "$name"
nmcli connection add ifname $if type ethernet con-name "$name" -- connection.autoconnect no connection.permissions user:$us 802-3-ethernet.mac-address "$mc" 802-3-ethernet.cloned-mac-address "$ms" 802-3-ethernet.wake-on-lan 32768 ipv4.method manual ipv4.addresses "$ip" ipv4.dns "208.67.222.222,208.67.220.220" ipv4.gateway "$gw" ipv4.ignore-auto-routes yes ipv4.ignore-auto-dns yes ipv4.dhcp-send-hostname no ipv6.method ignore
nmcli con up "$name"
