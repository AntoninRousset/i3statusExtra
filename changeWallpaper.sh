#!/bin/sh

wallpapersFolder="$HOME/.i3/wallpapers"
new="$(ls "$wallpapersFolder" | sort -R | tail -1)"
feh --bg-fill "$wallpapersFolder/$new"

