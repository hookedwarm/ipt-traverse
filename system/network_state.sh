#!/bin/bash
if (($1 == "0")); then
	nmcli networking off
elif (($1 == "1")); then
	nmcli networking on
fi
