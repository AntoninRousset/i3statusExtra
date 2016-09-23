#! /bin/sh

if [ -z "$1" ]; then
for l in "$(lsblk -o NAME,HOTPLUG,MODEL,SIZE -P -n -s)"; do
	name="$(echo "$l" | awk '/NAME/ {printf $1}')"
	name="${name%\"}"
	echo "HHH $name HHH"
done
fi

