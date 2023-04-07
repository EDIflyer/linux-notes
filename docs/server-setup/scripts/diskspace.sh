#!/bin/sh

# Purpose: Monitor Linux disk space and send an email alert to $ADMIN if $ALERT level reached
# Original script: https://www.cyberciti.biz/tips/shell-script-to-watch-the-disk-space.html
# Edited by: Alan J Robertson

printf "diskmonitor.sh run on $(date) - " >> /home/alan/disk.log
ALERT=80 # alert level
ADMIN="ajr@alanjrobertson.co.uk" # dev/sysadmin email ID
df -H /dev/sda | grep sda | awk '{ print $5 " " $1 }' | while read -r output;
do
  usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
  echo "currently used percentage = $usep%." >> /home/alan/disk.log
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Warning email sent $(date) as running out of space \"$partition ($usep%)\" on $(hostname)" >> /home/alan/disk.log
    printf "Subject: Disk space warning\n\nAlert: Almost out of disk space on Linode server - $usep%% used" | msmtp -d -a default "$ADMIN"
  fi
done