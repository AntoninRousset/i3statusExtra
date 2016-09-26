#! /bin/sh

notificationFile="tmp/notifications"
notificationDefaultDuration=3
source ~/.i3/i3statusExtra.conf

function checkDuration {
	case "$1" in
		''|*[!0-9]*) echo "'$1' is not a valid duration" 1>&2
			echo "$notificationDefaultDuration" ;;
		*) echo "$1" ;;
	esac
}

function checkMsg {
	case "$1" in
		''|*[!a-z][!A-Z]*) echo "'$1' is not a valid duration" 1>&2
			exit 1 ;;
		*) echo "$1" ;;
	esac
}

if [ -z "$1" ]; then
	echo "Usage: notify [--bad, --warn, --good] msg 24"
	echo "       notify --get"
	exit 1
fi

if [ "$1" == "--get" ] || [ "$1" == "-g" ]; then 
	sed -r -i 's/([0-9]+)/echo "$((\1-1))"/ge' "$notificationFile"
	sed -i.bak '/-[0-9]/d' "$notificationFile"
	cat "$notificationFile"
	exit 0
fi


importance=""
msg=""
duration=""
for arg in "$@"; do
	case "$arg" in
	"--bad") importance="!bad" ;;
	"--warn") importance="!warn" ;;
	"--good") importance="!good" ;;
	*) if [ -z "$msg" ]; then msg="$arg"; else duration="$arg"; fi ;;
	esac
done
echo "$( checkDuration "$duration") "$importance" $msg" >> "$notificationFile" 
killall -USR1 i3status
exit 1
