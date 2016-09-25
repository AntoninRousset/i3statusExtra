#!/bin/sh

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


i3status -c ~/.i3/i3status.conf | while :
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

# SOUND VOLUME
	sound=""
	for i in $(getSoundCards); do
		sound_cardId="$(echo $i | cut -d "=" -f 1)"
		sound_cardName="$(echo $i | cut -d "=" -f 2)"
		sound_cardVolume="$(getSoundCardVolume "$sound_cardId")"

		if [ -z "$sound_cardVolume" ]; then
			sound=$sound"$(block $cOrange "$sound_cardName " "$sound_cardId ")"
		else
			sound=$sound"$(block $cWhite "$sound_cardName   $sound_cardVolume" "$sound_cardId  $sound_cardVolume")"
		fi
	done

# WIRELESS

	w_ip="$(ifconfig | grep -A 2 wlan0 | awk '/^\s+inet\W/ {print $2}')"

	if [ -z "$w_ip" ]; then
		wireless="$(block "$cRed" " not connected" " -")"
	else
		wireless="$(block "$cGreen" " $w_ip" " $w_ip")"
	fi

# ETHERNET

	e_ip="$(ifconfig | grep -A 2 enp0s10 | awk '/^\s+inet\W/ {print $2}')"

	if [ -z "$e_ip" ]; then
		ethernet="$(block "$cRed" " not connected" " -")"
	else
		ethernet="$(block "$cGreen" " $e_ip" " $e_ip")"
	fi

# IPV6
	ipv6_ip="";
	if [ "$w_ip" ]; then
		ipv6_ip="$(ifconfig | grep -A 2 wlan0 | awk '/^\s+inet6\W/ {print $2}')"
	fi

	if [ -z "$ipv6_ip" -a "$e_ip" ]; then
		ipv6_ip="$(ifconfig | grep -A 2 enp0s10 | awk '/^\s+inet6\W/ {print $2}')"
		echo "asdkine $ipv6_ip" > /tmp/cards
	fi

	if [ "$ipv6_ip" ]; then
		ipv6="$(block "$cGreen" "IPv6 $ipv6_ip" "$ipv6_ip")"
	else
		ipv6=""
	fi
		

# BATTERY

	b_charging=$(if [ "$(acpi | awk '{print $3}')" == "Charging," ]; then
			echo ""
		     fi)
	b_charge_percent=$(acpi | awk 'BEGIN {FS="[% ]"} /Battery/ {print $4}')	

	b_logos="    "
	for i in `seq 1 5`; do
		if [ "$b_charge_percent" -ge "$(echo "($i-1)*20" | bc)" ]; then
			b_logo="$(echo "$b_logos" | cut -d " " -f $i )"
		fi
	done

	if [ "$b_charge_percent" -le "$battery_alert" ]; then
		b_color="$cRed"
	elif [ "$b_charge_percent" -le "$battery_warning" ]; then
		b_color="$cOrange"
	elif [ "$b_charge_percent" -ge "$battery_good" ]; then
		b_color="$cGreen"
	else
		b_color="$cWhite"
	fi

	battery="$(block "$b_color" "$b_charging $b_logo $b_charge_percent%" "$b_logo $b_charge_percent%" )"


# Backlight
	bl_brightness="$(block "$cWhite" "☀ $(sh ~/.i3/bl-brightness.sh)%")" 

# ECHO

	#cat /tmp/pouet
if [ "$shortcuts" ]; then
	echo "${line/\[*\]/\["$shortcuts"\]}"
else
	echo "${line/\[/\[$notification$ethernet$wireless$ipv6$bl_brightness$battery$sound}"
fi
done

