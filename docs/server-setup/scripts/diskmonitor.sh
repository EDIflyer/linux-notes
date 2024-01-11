#!/bin/bash

# Purpose: Monitor Linux disk space and send an email alert to $ADMIN if $ALERT level reached
# Original script: https://www.cyberciti.biz/tips/shell-script-to-watch-the-disk-space.html
# Edited by: Alan J Robertson

ALERT=75 # alert level
TONAME="Alan Robertson"
TOEMAIL="ajr@alanjrobertson.co.uk"
FROMNAME="Linode Server"
FROMEMAIL="webmaster@alanjrobertson.co.uk"
LOGFILE="/home/alan/scripts/diskmonitor.log"

printf "diskmonitor.sh run on $(date) - " >> $LOGFILE

if [ "$1" == "weekly" ]; then 
  # weekly update email option selected
  printf "weekly email option selected" >> $LOGFILE
  printf "To: $TONAME <$TOEMAIL>\nFrom: $FROMNAME <$FROMEMAIL>\nSubject: Disk monitor weekly update\n\n" > /tmp/weeklyemail.msg
  cat $LOGFILE >> /tmp/weeklyemail.msg
  printf "\n[Sent: $(date)]" >> /tmp/weeklyemail.msg
  cat /tmp/weeklyemail.msg | msmtp -d -t > /tmp/email.out ; rm /tmp/weeklyemail.msg
  rm $LOGFILE; echo "Logfile reset [$(date)]" >> $LOGFILE
  docker stop dozzle-from-file-diskmonitor
  docker rm dozzle-from-file-diskmonitor
  docker compose -f /home/alan/scripts/diskmonitor_stream.yaml up --detach  
else
  # routine daily check
  df -H /dev/sda | grep sda | awk '{ print $5 " " $1 }' | while read -r output;
  do
    usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
    echo "currently used percentage = $usep% (warning limit set to $ALERT%)." >> $LOGFILE
    partition=$(echo "$output" | awk '{ print $2 }' )
    if [ $usep -ge $ALERT ]; then
      echo "Warning email sent $(date) as running out of space on $partition ($usep%)" >> $LOGFILE
      printf "To: $TONAME <$TOEMAIL>\nFrom: $FROMNAME <$FROMEMAIL>\nSubject: Disk space warning\n\nAlert: Running out of disk space on Linode server - $usep%% used (warning limit set to $ALERT%%).\n[Sent: $(date)]" | msmtp -d -t
    fi
  done
fi