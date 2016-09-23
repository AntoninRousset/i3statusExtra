#!/bin/sh

SHORTCUTBAR_FILE="/tmp/shortcutBar"

cWhite="#ffffff"
cGray="#a0a0a0"
cGreen="#20c020"
cOrange="#ffe000"
cRed="#c00000"

names=( "Mount Bridge" "Turn on ethernet" "Turn on wifi" "Turn on laptop_mode" "Suspend")
exes=( "mount /mnt/Bridge" "sudo rc-service net.enp0s10 start; sudo rc-service privoxy start" "sudo rc-service net.wlan0 start && sudo rc-service privoxy start" "sudo rc-service laptop_mode start" "sudp pm-suspend")
selected="$(cat $SHORTCUTBAR_FILE)"

if [ "$(cat /etc/mtab | grep Bridge)" ]; then
	names[0]="Umount Bridge"
	exes[0]="umount /mnt/Bridge"
fi

if [ "$(ifconfig | grep enp0s10)" ]; then
	names[1]="Turn off ethernet"
	exes[1]="sudo rc-service net.enp0s10 stop"
fi

if [ "$(ifconfig | grep wlan0)" ]; then
	names[2]="Turn off wifi"
	exes[2]="sudo rc-service net.wlan0 stop"
fi

function toggleNetService {
	status="$(rc-status | grep "net.$1" | cut -d [ -f 2 | cut -d ] -f 1)"
	if [ "$status" == "  stopped  " ]; then
		sudo rc-service net.$1 start > /dev/null
	else
		sudo rc-service net.$1 stop > /dev/null
	fi
}

function block {
	echo '{"name": "asdf", "color": "'"$1"'", "full_text": "'"$2"'", "short_text": "'"$3"'"}'
}

if [ -z "$1" ]; then
	if [ -z "$selected" ]; then
		exit 1
	fi
	line=""
	i=0
	for name in "${names[@]}"; do
		if [ $i == $selected ]; then
			line="$line$(block "$cWhite" "$name" "we"),"
		else
			line="$line$(block "$cGray" "$name" "we"),"
		fi
		i=$(($i+1))
	done
	echo "${line%?}" 
	exit 0
fi

case "$1" in
	'enable')
		echo 0 > $SHORTCUTBAR_FILE
		killall -USR1 i3status
		exit 1;;
	'disable')
		echo '' > $SHORTCUTBAR_FILE
		killall -USR1 i3status
		exit 1;;
	'+')
		echo $(($selected + 1)) > $SHORTCUTBAR_FILE
		killall -USR1 i3status
		exit 1;;
	'-')
		echo $(($selected - 1)) > $SHORTCUTBAR_FILE
		killall -USR1 i3status
		exit 1;;
	'select')
		${exes[$selected]} || ~/.i3/i3status.sh notify "${names[$selected]} failed"
		echo '' > $SHORTCUTBAR_FILE
		killall -USR1 i3status
		exit 1;;

esac


