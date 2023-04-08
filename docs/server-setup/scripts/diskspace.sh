#!/bin/sh

# Purpose: Monitor Linux disk space and send an email alert to $ADMIN if $ALERT level reached
# Original script: https://www.cyberciti.biz/tips/shell-script-to-watch-the-disk-space.html
# Edited by: Alan J Robertson

printf "diskmonitor.sh run on $(date) - " >> /home/alan/disk.log
ALERT=80 # alert level
TONAME="Alan Robertson"
TOEMAIL="ajr@alanjrobertson.co.uk" # dev/sysadmin email ID
FROMEMAIL="webmaster@alanjrobertson.co.uk"
df -H /dev/sda | grep sda | awk '{ print $5 " " $1 }' | while read -r output;
do
  usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
  echo "currently used percentage = $usep% (warning limit set to $ALERT%)." >> /home/alan/disk.log
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Warning email sent $(date) as running out of space on $partition ($usep%)" >> /home/alan/disk.log
    printf "To: $TONAME <$TOEMAIL>\nFrom: Linode Server <$FROMEMAIL>\nSubject: Disk space warning\n\nAlert: Running out of disk space on Linode server - $usep%% used (warning limit set to $ALERT%%).\n[Sent: $(date)]" | msmtp -d -t
  fi
done