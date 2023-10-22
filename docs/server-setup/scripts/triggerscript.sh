#!/bin/bash -e
# Note the '-e' in the line above. This is required for error trapping implemented below.
# Original author Annson Van Doren https://ansonvandoren.com/posts/telegram-notification-on-deploy/
# Adapted by AJR July 2022

# Repo name on GitHub - **BE SURE TO USE SSH RATHER THAN HTTPS**
REMOTE_REPO=git@github.com:EDIflyer/linux-notes.git
# A place to clone the remote repo so the static site generator can build from it; can't use $HOME as runs as root
WORKING_DIRECTORY=/home/<user>/repositories/linux-notes
# Location (server block) where the Nginx container looks for content to serve
PUBLIC_WWW=/var/www/docs.alanjrobertson.co.uk/html
# Backup folder in case something goes wrong during this script
BACKUP_WWW=/home/<user>/docs/backup_html
# Domain name so Hugo can generate links correctly
MY_DOMAIN=docs.alanjrobertson.co.uk

# Set up Telegram
TOKEN=INSERT_TOKEN_HERE
CHAT_ID=INSERT_CHAT_ID_HERE
BOT_URL="https://api.telegram.org/bot$TOKEN/sendMessage"

# Send messages to Telegram bot
function send_msg () {
    # Use "$1" to get the first argument (desired message) passed to this function
    # Set parsing mode to HTML because Markdown tags don't play nice in a bash script
    # Redirect curl output to /dev/null since we don't need to see it
    # (it just replays the message from the bot API)
    # Redirect stderr to stdout so we can still see an error message in curl if it occurs
    curl -s -X POST $BOT_URL -d chat_id=$CHAT_ID -d text="$1" -d parse_mode="HTML" > /dev/null 2>&1
}

# These parameters are passed by the webhook to the script - see the hooks.json `pass-arguments-to-command` section
commit_message=$1
pusher_name=$2
commit_id=$3

# If something goes wrong, put the previous verison back in place
function cleanup {
    ERROR=$?
    echo "A problem occurred. Reverting to backup."
    rsync -aqz --del $BACKUP_WWW/ $PUBLIC_WWW
    rm -rf $WORKING_DIRECTORY
    
    # Use $? to get the error message that caused the failure
    send_msg "<b>Deployment of $MY_DOMAIN failed:</b> $ERROR"
}

# Call the cleanup function if this script exits abnormally. The -e flag
# in the shebang line ensures an immediate abnormal exit on any error
trap cleanup EXIT

# Clear out the working directory
rm -rf $WORKING_DIRECTORY
# Make a backup copy of current website version
# --mkpath flag causes destination directories to be created
rsync -avz --mkpath $PUBLIC_WWW/ $BACKUP_WWW

# Clone the new version from GitHub
git clone $REMOTE_REPO $WORKING_DIRECTORY

send_msg "<i>Successfully cloned Github repo for $MY_DOMAIN</i>
<code>Message: $commit_message</code>
<code>Commit ID: $commit_id</code>
<code>Pushed by: $pusher_name</code>"

# Delete old version
rm -rf $PUBLIC_WWW/*
# Have mkdocs-material generate the new static HTML directly into the public WWW folder
# Save the output to send to Telegram
mkdocs_response=$(docker run --rm -i -v $WORKING_DIRECTORY:/docs custom/mkdocs-material build)
cp -r $WORKING_DIRECTORY/site/* $PUBLIC_WWW
# Send response to bot as a fenced code block to preserve formatting
send_msg "<pre>$mkdocs_response</pre>"

# All done!
send_msg "<b>Deployment successful!</b>"

# Clear out working directory
rm -rf $WORKING_DIRECTORY
# Exit without trapping, since everything went well
trap - EXIT