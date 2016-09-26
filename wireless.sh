#!/bin/bash

source ~/.i3/i3statusExtra.conf

if [ -z $1 ] || [ "$1" == "get" ]; then
	case "$(ifconfig "$wi_card" | head -1)" in
	*UP*)
		info=$(wpa_cli status)
		echo "$(echo "$info" | sed -n -e 's/^wpa_state=//p')"\
		     "$(echo "$info" | sed -n -e 's/^ssid=//p')"\
		     "$(echo "$info" | sed -n -e 's/^ip_address=//p')";;
	*)
		echo "off";;
	esac
else
	echo "wireless: invalid argument '"$1"'" > /dev/stderr
	exit 1
fi
