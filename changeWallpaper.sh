#!/bin/sh

source ~/.i3/i3statusExtra.conf

if [[ "$1" ]]; then
	feh --bg-fill "${wp_folder}/${1}.*"
	exit 0
fi

case "$wp_sort" in
	random)
		new="$(find "$wp_folder" -type f | shuf -n1)";;
	natural)
		;;
	*)
		echo "changeWallpaper: Unrecognized sort '"$wp_sort"'" > /dev/stderr
		exit 1;;
esac

/usr/bin/feh --bg-fill "$new"

