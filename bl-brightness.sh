#!/bin/bash

step=21
smallStep=7

hasXbacklight='right'
brightnessFile=''

if [ -z $1 ]; then
	echo "bl-brightness: No argument given" > /dev/stderr
elif [ "$1" == "up" ]; then
	xbacklight -time 120 -inc $step
elif [ "$1" == "UP" ]; then
	xbacklight -time 40 -inc $smallStep
elif [ "$1" == "down" ]; then
	xbacklight -time 120 -dec $step
elif [ "$1" == "DOWN" ]; then
	xbacklight -time 40 -dec $smallStep
elif [ "$1" == "on" ]; then
	xbacklight -time 0 -set 100
elif [ "$1" == "off" ]; then
	xbacklight -time 0 -set 0
else
	case $1 in
    	''|*[!0-9]*) echo "bl-brightness: Unknown argument '"$1"'" > /dev/stderr ;;
    	*) xbacklight -set $1;;
	esac
fi

