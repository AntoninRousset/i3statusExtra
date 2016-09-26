#!/bin/bash

source ~/.i3/i3statusExtra.conf

if [ -z $1 ] || [ "$1" == "get" ]; then
	info="$(amixer -c 0 sget Master)"
	echo "$(echo "$info" | awk -F"[][]" '/dB/ { print $6; exit;}')"\
	     "$(echo "$info" | awk -F"[][]" '/dB/ { print $2; exit;}')"
	exit 0
fi

case "$1" in
	mute)
		echo "mute" >> "log"
		#if amixer -q -c 1 set PCM toggle; then exit 0; fi
		if amixer -q -c 0 set Master toggle; then exit 0; fi
		echo "volume: unable to mute'"$1"'" > /dev/stderr
		exit 1;;
	up)
		amount="$so_step+";;
	down)
		amount="$so_step-";;
	UP)
		amount="$so_smallStep+";;
	DOWN)
		amount="$so_smallStep-";;
	*)
		echo "volume: invalid argument '"$1"'" > /dev/stderr
		exit 1;;
esac

#if amixer -q -c 1 set PCM $amount unmute; then exit 0; fi
if amixer -q -c 0 set Master $amount unmute; then exit 0; fi
echo "volume: unable to change volume" > /dev/stderr
exit 1
