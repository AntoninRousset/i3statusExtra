#! /bin/bash

source ~/.i3/i3statusExtra.conf

eval path="$ss_folder/$ss_name.$ss_format"

xwd -root | convert xwd:- "$path" && ~/.i3/i3status.sh notify "Screenshot saved in $path.$ss_format"

