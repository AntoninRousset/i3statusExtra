#!/bin/sh

source ~/.i3/i3statusExtra.conf

if [ -z $1 ] || [ "$1" == "get" ]; then
	printf "%.0f" "$(xbacklight -get)"
	exit 0
fi
case "$1" in
	up)
		xbacklight -time 120 -inc $bl_step;;
	down)
		xbacklight -time 120 -dec $bl_step;;
	UP)
		xbacklight -time 40 -inc $bl_smallStep;;
	DOWN)
		xbacklight -time 40 -dec $bl_smallStep;;
	on)
		xbacklight -time 0 -set 100;;
	off)
		xbacklight -time 0 -set 0;;
	*)
		case $1 in
    			''|*[!0-9]*) echo "bl-brightness: Unknown argument
				'"$1"'" > /dev/stderr
				exit 1;;
    		*) xbacklight -set $1;;
		esac;;
esac

