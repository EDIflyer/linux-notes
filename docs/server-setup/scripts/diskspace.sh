#!/bin/sh

# Purpose: Monitor Linux disk space and send an email alert to $ADMIN if $ALERT level reached
# Original script: https://www.cyberciti.biz/tips/shell-script-to-watch-the-disk-space.html
# Edited by: Alan J Robertson

ALERT=80 # alert level
ADMIN="ajr@alanjrobertson.co.uk" # dev/sysadmin email ID
df -H /dev/sda | grep sda | awk '{ print $5 " " $1 }' | while read -r output;
do
  echo "$output"
  usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)"
    # remember %% required with printf as % is a special character
    printf "Subject: Disk space warning\n\nAlert: Almost out of disk space on Linode server - $usep%% used" | msmtp -d -a default "$ADMIN"
  fi
done