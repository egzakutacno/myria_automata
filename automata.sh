#!/usr/bin/env bash
# config.sh

config_file="config.txt"

# Check if the configuration file exists
if [ -f "$config_file" ]; then
    # Configuration file exists, source it
    source "$config_file"
else
    # Ask the user for API keys and other configurations
    read -p "Enter Your Node 1 API: " input_text1
    read -p "Enter Your Node 2 API: " input_text2
    read -p "Enter Your Node 3 API (press:↵ Enter to skip): " input_text3
    read -p "Enter your Telegram Bot Token (press:↵ Enter to continue without telegram notifications): " bot_token
    read -p "Enter your Telegram Chat ID (press:↵ Enter to continue without telegram notifications): " chat_id
    read -p "Enter the work duration of each node (e.g., 6h 20m): " work_duration
    telegram_url="https://api.telegram.org/bot$bot_token/sendMessage"
    #start_time="12:09"  # Set the desired start time in HH:MM format
    # Set the Telegram URL using the provided bot token
    telegram_url="https://api.telegram.org/bot$bot_token/sendMessage"

    # Save the entered values to the configuration file
    echo "input_text1=\"$input_text1\"" > "$config_file"
    echo "input_text2=\"$input_text2\"" >> "$config_file"
    echo "input_text3=\"$input_text3\"" >> "$config_file"
    echo "bot_token=\"$bot_token\"" >> "$config_file"
    echo "chat_id=\"$chat_id\"" >> "$config_file"
    echo "work_duration=\"$work_duration\"" >> "$config_file"
fi

# main.sh

# Source the configuration file
# source config.sh
start_command="/usr/local/bin/myria-node --start"
stop_command="/usr/local/bin/myria-node --stop"

# Function to send a notification with input text
send_notification() {
    local notification_text="$1"
    if [ -n "$bot_token" ] && [ -n "$chat_id" ]; then
        # Assuming you construct the telegram_url using bot_token
        telegram_url="https://api.telegram.org/bot$bot_token/sendMessage"
        curl -s -X POST "$telegram_url" -d chat_id="$chat_id" -d text="$notification_text"
    else
        echo "Bot token or chat_id is not set. Skipping notification."
    fi
}



#Function to start the service with input text
start_service() {
    local input_text="$1"
    echo "$input_text" | $start_command

    # Check if the service started successfully
    if [ $? -eq 0 ]; then
        echo "Service started successfully"
        send_notification "Service started successfully"
    else
        echo "Failed to start service"
        send_notification "Failed to start service"
        exit 1
    fi
}

# Function to stop the service with input text
stop_service() {
    local input_text="$1"
    echo "$input_text" | $stop_command

    # Check if the service stopped successfully
    if [ $? -eq 0 ]; then
        echo "Service stopped successfully"
        send_notification "Service stopped successfully"
    else
        echo "Failed to stop service"
        send_notification "Failed to stop service"
    fi
}

counter=0

while true; do
    # Get the current time in 24-hour format
    current_time=$(date +%H:%M)

    # Calculate the time difference in minutes
    desired_minutes=$(date -d "$start_time" +%s)
    current_minutes=$(date -d "$current_time" +%s)

    time_difference=$((desired_minutes - current_minutes))

    # Check if the desired time is in the future
    if [ $time_difference -gt 0 ]; then
        echo "Waiting until $start_time to run the command..."
        sleep $time_difference
    else
        echo "Executing your command at $start_time"

        if [ -n "$input_text1" ]; then
            ((counter++))
            echo "The value of API is: $input_text1"
            start_service "$input_text1"

            # Check if bot_token is set before using curl for Telegram
            if [ -n "$bot_token" ]; then
                output=$(/usr/local/bin/myria-node --status)
                # Format the output for sending via Telegram
                message=$(echo -e "Command output:\n$output")
                echo "$message"
                if [ -n "$chat_id" ]; then
                    send_notification "$message"
                else
                    echo "Telegram chat_id is not set. Skipping notification."
                fi
            else
                echo "Telegram bot_token is not set. Skipping notification."
            fi

            sleep $work_duration
            stop_service "$input_text1"
        else
            echo "Variable1 does not exist."
        fi

        if [ -n "$input_text2" ]; then 
            ((counter++))
            echo "The value of API is: $input_text2"
            start_service "$input_text2"

            # Check if bot_token is set before using curl for Telegram
            if [ -n "$bot_token" ]; then
                output=$(/usr/local/bin/myria-node --status)
                # Format the output for sending via Telegram
                message=$(echo -e "Command output:\n$output")
                echo "$message"
                if [ -n "$chat_id" ]; then
                    send_notification "$message"
                else
                    echo "Telegram chat_id is not set. Skipping notification."
                fi
            else
                echo "Telegram bot_token is not set. Skipping notification."
            fi

            sleep $work_duration
            stop_service "$input_text2"
        else
            echo "Variable2 does not exist."
        fi

        if [ -n "$input_text3" ]; then
            ((counter++))
            echo "The value of API is: $input_text3"
            start_service "$input_text3"

            # Check if bot_token is set before using curl for Telegram
            if [ -n "$bot_token" ]; then
                output=$(/usr/local/bin/myria-node --status)
                # Format the output for sending via Telegram
                message=$(echo -e "Command output:\n$output")
                echo "$message"
                if [ -n "$chat_id" ]; then
                    send_notification "$message"
                else
                    echo "Telegram chat_id is not set. Skipping notification."
                fi
            else
                echo "Telegram bot_token is not set. Skipping notification."
            fi

            sleep $work_duration
            stop_service "$input_text3"
        else
            echo "Variable3 does not exist."
        fi

        # Exit the script after running the commands
        exit 0
    fi
done
