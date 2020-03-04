#!/bin/bash
if="$(cat devices/${1}/int)"
mc="$(cat devices/${1}/intmac)"
ms="$(cat devices/${1}/ints)"
# TODO: mask should be passed
ip="$(cat devices/${1}/ip2)/8"
gw="10.0.0.1"
us="$(cat devices/${1}/user)"
if [[ "$7" == "" ]]; then
	name="Wired connection 1"
else
	name="$7"
fi
nmcli radio all off
nmcli connection delete "$name"
nmcli connection add ifname $if type ethernet con-name "$name" -- connection.autoconnect no connection.permissions user:$us 802-3-ethernet.mac-address "$mc" 802-3-ethernet.cloned-mac-address "$ms" 802-3-ethernet.wake-on-lan ignore ipv4.method manual ipv4.dns "" ipv4.addresses "$ip" ipv4.gateway "$gw" ipv4.ignore-auto-routes yes ipv4.ignore-auto-dns yes ipv4.may-fail no ipv4.dhcp-send-hostname no ipv4.dhcp-hostname user ipv6.method ignore
nmcli con up "$name"
