#!/bin/sh

source ~/.i3/i3statusExtra.conf

if [ -z $1 ] || [ "$1" == "get" ]; then

	# Without ACPI
	if [ "$ba_acpi" = false ]; then
		state="$(cat "${ba_battery}/status")"
		now="$(cat "${ba_battery}/charge_now")"
		full="$(cat "${ba_battery}/charge_full_design")"
		if ("$(cat "${ba_adapter}/online")" == 1); then ac="on-line"
		else ac="off-line"; fi
		echo "$state" "$((100*$now/$full))%" "$ac"
		exit 0
	fi

	# With ACPI
	state=$(acpi -b | awk '{print substr($3,1,length($3)-1)}')
	ratio=$(acpi -b | awk 'BEGIN {FS="[% ]"} /Battery/ {print $4}')	
	ac=$(acpi -a | awk '{print $3}')
	echo "$state" "$ratio%" "$ac"
	exit 0

else
	echo "wireless: invalid argument '"$1"'" > /dev/stderr
	exit 1
fi
