#!/bin/bash

# Not ready #TODO

step=20
smallStep=5

if [ -z $1 ]; then
	echo "volume: No argument given" > /dev/stderr
elif [ "$1" == "mute" ]; then
	if amixer -q -c 1 set PCM toggle; then exit 0; fi
	if amixer -q -c 0 set Master toggle; then exit 0; fi
	echo "volume: unable to mute'"$1"'" > /dev/stderr
	exit 1
elif [ "$1" == "up" ]; then amount="$step+";
elif [ "$1" == "down" ]; then amount="$step-";
elif [ "$1" == "UP" ]; then amount="$smallStep+";
elif [ "$1" == "DOWN" ]; then amount="$smallStep-";
else
	echo "volume: invalid argument '"$1"'" > /dev/stderr
	exit 1
fi

if amixer -q -c 1 set PCM $amount unmute; then exit 0; fi
if amixer -q -c 0 set Master $amount unmute; then exit 0; fi
echo "volume: unable to change volume" > /dev/stderr
exit 1
