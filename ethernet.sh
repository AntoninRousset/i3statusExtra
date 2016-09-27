#!/bin/bash

source ~/.i3/i3statusExtra.conf

info=$(ifconfig "$et_card" | head -2)
if [ -z $1 ] || [ "$1" == "get" ]; then
	case "$(echo "$info" | head -1)" in
	*RUNNING*)
		ip=$(echo "$info" | awk '/^\s+inet\W/ {print $2}')
		if [ -z $ip ]; then echo "CONNECTING"
		else echo "CONNECTED" "$ip"; fi;;
	*UP*)
		echo "DISCONNECTED";;
	*)
		echo "OFF";;
	esac
else
	echo "wireless: invalid argument '"$1"'" > /dev/stderr
	exit 1
fi
