#!/bin/bash
#!/bin/sh
# The command you want to schedule
command="/bin/bash  /home/luigy/Programming/gnosis/xdaibridge-keeper/runCronjob.sh"

# The cron schedule expression for every 2 minutes
schedule="*/2 * * * *"

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
