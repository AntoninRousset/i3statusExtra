#!/bin/bash

source ~/.i3/i3statusExtra.conf

case "$wp_sort" in
	random)
		new="$(find /home/antonin/Wallpapers -type f | shuf -n1)";;
	natural)
		;;
	*)
		echo "changeWallpaper: Unrecognized sort '"$wp_sort"'" > /dev/stderr
		exit 1;;
esac

/usr/bin/feh --bg-fill "$new"
