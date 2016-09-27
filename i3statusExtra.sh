#!/bin/bash

source ~/.i3/i3statusExtra.conf

notificationFile="/tmp/notification"
notificationTimeFile="/tmp/notificationTime"
notificationDuration=3

battery_good=80
battery_warning=40
battery_alert=10

cWhite="#ffffff"
cGreen="#20c020"
cOrange="#ffe000"
cRed="#c00000"

function block {
	if [ -z $3 ]; then st="$2"; else st="$3"; fi
	echo '{ "color": "'"$1"'", "full_text": "'"$2"'", "short_text": "'"$st"'"},'
}

function getSoundCards {
        echo "$(aplay -l | awk 'BEGIN {lastN = ""}
				/card/ {n = substr($2, 0, 1);
					if (n != lastN) {
						lastN = n;
						printf n"="$3" "
					}
			}')"
}

# return "" if muted
function getSoundCardVolume {
	soundCardInfo="$(amixer -c $1 sget Master)"
	if [ -z "$soundCardInfo" ]; then
		soundCardInfo="$(amixer -c $1 sget PCM 2>/dev/null)"
	fi

	
	if [ "$(echo "$soundCardInfo" | awk -F"[][]" '/dB/ { print $6; exit;}')" == "on" ]; then
		echo "$(echo "$soundCardInfo" | awk -F"[][]" '/dB/ { print $2; exit;}')"
	fi
}

if [ "$1" == "notify" ]; then
	echo "$2" > "$notificationFile" 
	echo "$notificationDuration" > "$notificationTimeFile" 
	killall -USR1 i3status
	exit 1
fi

/usr/bin/i3status -c ~/.i3/i3status.conf | while :
do
	read line

shortcuts="$(~/.i3/shortcutsBar.sh)"

# NOTIFICATIONS
	notification="$(cat $notificationFile 2>/dev/null)"
	notificationTime="$(cat $notificationTimeFile 2>/dev/null)"
	if [ "$notification" ]; then
		notification="$(block "$cWhite" "$notification" "$notification")"
		echo "$(( $notificationTime - 1 ))" > "$notificationTimeFile"
		if [ "$notificationTime" -le "1" ]; then
			echo '' > "$notificationFile"
			echo '' > "$notificationTimeFile"
		fi
	fi

# Sound
sound=''
if [ "$so_bar" = true ]; then
	set $(sh ~/.i3/sound.sh get)
	if [ "$1" == "on" ]; then sound="$(block "$cWhite" "  $2")";
	else sound="$(block "$cOrange" "   $2")"; fi
fi

# Wireless
wireless=''
if [ "$wi_bar" = true ]; then
	set $(sh ~/.i3/wireless.sh get)
	case "$1" in
	COMPLETED)
		wireless="$(block "$cGreen" " ${2:0:16} $3" " ${2:0:6}")";;
	SCANNING)
		wireless="$(block "$cOrange" " Scanning" " -")";;
	DISCONNECTED)
		wireless="$(block "$cRed" " Disconnected" " -")";;
	ASSOCIATING)
		wireless="$(block "$cOrange" " Associating" " +")";;
	ASSOCIATED)
		wireless="$(block "$cOrange" " Associated" " +")";;
	AUTHENTICATING)
		wireless="$(block "$cOrange" " Autentificating" " +")";;
	4WAY_HANDSHAKE|GROUP_HANDSHAKE)
		wireless="$(block "$cOrange" " Handshake" " +")";;
	INACTIVE)
		wireless="$(block "$cOrange" " Inactive" " +")";;
	INTERFACE_DISABLED)
		wireless="$(block "$cOrange" " Disabled" " +")";;
	OFF)
		wireless="$(block "$cRed" " OFF" " -")";;
	esac
fi

# ETHERNET
ip="$(ifconfig | grep -A 2 enp0s10 | awk '/^\s+inet\W/ {print $2}')"

if [ -z "$e_ip" ]; then
	ethernet="$(block "$cRed" " not connected" " -")"
else
	ethernet="$(block "$cGreen" " $e_ip" " $e_ip")"
fi

# BATTERY

battery=''
if [ "$ba_bar" = true ]; then
	set $(sh ~/.i3/battery.sh get)
	logos="     "
	for i in {0..8..2}; do
		if [ $(echo $2 | tr -d '%') -le $((100-$i*12)) ]; then
			logo=${logos:$i:2}
		else
			break
		fi
	done
	if [ "$3" == "on-line" ]; then logo=" $logo"; fi
	if [ $(echo $2 | tr -d '%') -le $ba_alert ]; then color="$cRed"
	elif [ $(echo $2 | tr -d '%') -le $ba_warning ]; then color="$cOrange"
	else color="$cGreen"; fi
	battery="$(block "$color" "$logo$2" "$logo$2")"
fi

# Backlight
	bl_brightness=''
	if [ "$bl_bar" = true ]; then
		set $(sh ~/.i3/bl-brightness.sh get)
		bl_brightness="$(block "$cWhite" "☀ $1%")" 
	fi

# ECHO

	#cat /tmp/pouet
if [ "$shortcuts" ]; then
	echo "${line/\[*\]/\["$shortcuts"\]}"
else
	echo "${line/\[/\[$notification$ethernet$wireless$ipv6$bl_brightness$battery$sound}"
fi
done

