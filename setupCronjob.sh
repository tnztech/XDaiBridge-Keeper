#!/bin/bash

# The command you want to schedule
command="cd /home/luigy/Programming/gnosis/xdaibridge-keeper & make run-keeper"

# The cron schedule expression for every hour
schedule="0 * * * *"

# Write out current crontab
crontab -l > mycron

# Check if the cron job already exists
if grep -Fxq "$schedule $command" mycron
then
    echo "Cron job already exists. No action taken."
else
    # Echo new cron into cron file
    echo "$schedule $command" >> mycron

    # Install new cron file
    crontab mycron

    echo "Cron job added."
fi

# Remove the temporary cron file
rm mycron
