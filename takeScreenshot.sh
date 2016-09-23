#! /bin/sh

screenshotsFolder="$HOME/Images"
screenshotName="Screenshot-$(date +"%d_%m_%y-%k:%M:%S")"
screenshotFormat="tiff"

xwd -root > "${screenshotsFolder}/${screenshotName}"'.xwd' && convert "${screenshotsFolder}/${screenshotName}.xwd" "${screenshotsFolder}/${screenshotName}.${screenshotFormat}" && rm "${screenshotsFolder}/${screenshotName}.xwd" && $HOME/.i3/i3status.sh notify "Screenshot saved in ${screenshotsFolder}/${screenshotName}.${screenshotFormat}"

