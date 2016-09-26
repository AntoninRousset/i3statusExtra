#!/bin/bash

if [[ "$1" ]]; then
	feh --bg-fill "$1"
	exit 0
fi

wallpapersFolder="$HOME/Images/wallpapers"
new="$(ls "$wallpapersFolder" | sort -R | tail -1)"
feh --bg-fill "$wallpapersFolder/$new"
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

