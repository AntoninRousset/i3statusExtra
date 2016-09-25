#!/bin/sh

if [[ "$1" ]]; then
	feh --bg-fill "$1"
	exit 0
fi

wallpapersFolder="$HOME/Images/wallpapers"
new="$(ls "$wallpapersFolder" | sort -R | tail -1)"
feh --bg-fill "$wallpapersFolder/$new"

