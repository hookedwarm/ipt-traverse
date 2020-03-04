#!/bin/bash
if="$(cat devices/${1}/ext)"
mc="$(cat devices/${1}/extmac)"
ms="$(cat devices/${1}/exts)"
ip="na"
gw="na"
us="$(cat devices/${1}/user)"
if [[ "$7" == "" ]]; then
	name="Wired connection 1"
else
	name="$2"
fi
nmcli radio all off
nmcli connection delete "$name"
nmcli connection add ifname $if type ethernet con-name "$name" -- connection.autoconnect no connection.permissions user:$us 802-3-ethernet.mac-address "$mc" 802-3-ethernet.cloned-mac-address "$ms" 802-3-ethernet.wake-on-lan ignore ipv4.method auto ipv4.ignore-auto-dns yes ipv6.method ignore
nmcli con up "$name"
