#!/bin/bash

# allow networking time to come up
sleep 120

# Set up Telegram
TOKEN=[INSERTTOKEN]
CHAT_ID=[INSERTCHATID]
BOT_URL="https://api.telegram.org/bot$TOKEN/sendMessage"

# Send messages to Telegram bot
function send_msg () {
    # Use "$1" to get the first argument (desired message) passed to this function
    # Set parsing mode to HTML because Markdown tags don't play nice in a bash script
    # Redirect curl output to /dev/null since we don't need to see it
    # (it just replays the message from the bot API)
    # Redirect stderr to stdout so we can still see an error message in curl if it occurs
    curl -s -X POST $BOT_URL -d chat_id=$CHAT_ID -d text="$1" -d parse_mode="HTML" 2>&1
}

send_msg "<b>Pi 400 in Gourlay Yard has rebooted!</b>"

echo "Reboot at $(date) [minus 2 min]" >> reboot.log