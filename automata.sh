#!/bin/bash
# config.sh

config_file="config.txt"

# Check if the configuration file exists
if [ -f "$config_file" ]; then
    # Configuration file exists, source it
    source "$config_file"
else
    # Ask the user for API keys and other configurations
    read -p "Enter Your_Node 1 API: " input_text1
    read -p "Enter Your_Node 2 API: " input_text2
    read -p "Enter Your_Node 3 API (press:↵ Enter to skip) : " input_text3
    read -p "Enter your Telegram Bot Token (press:↵ Enter to continiue without telegram notifications) : " bot_token
    read -p "Enter your Telegram Chat ID (press:↵ Enter to continiue without telegram notifications): " chat_id
    read -p "Enter the work duration of each node (e.g., 6h 20m): " work_duration

    start_time="08:03"  # Set the desired start time in HH:MM format
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

# Function to start the service with input text
send_notification() {
    local notification_text="$1"
    curl -s -X POST $telegram_url -d chat_id=$chat_id -d text="$notification_text"
}

# Function to start the service with input text
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


while true; do
    counter=0
    # Get the current time in 24-hour format
    current_time=$(date +%H:%M)

    # Calculate the time difference in minutes
    desired_minutes=$(date -d "$start_time" +%s)
    current_minutes=$(date -d "$current_time" +%s)
    midnight_minutes=$(date -d "tomorrow" +%s)

    time_difference=$((desired_minutes - current_minutes))

    # Check if the desired time is in the future
    if [ $time_difference -gt 0 ]; then
        echo "Waiting until $desired_time to run the command..."
        sleep $time_difference
    else
        # The desired time has already passed; calculate the time until the next day
        time_until_midnight=$((midnight_minutes - current_minutes))
        time_until_desired=$((time_until_midnight + desired_minutes))

        echo "Waiting until tomorrow $desired_time to run the command..."
        sleep $time_until_desired
    fi

    # Run your command here
    echo "Executing your command at $desired_time"

    if [ -n "$input_text1" ]; then
        ((counter++))
        echo "The value of API is: $input_text1"
        start_service $input_text1
        output=$(/usr/local/bin/myria-node --status)
        #    Format the output for sending via Telegram
        message=$(echo -e "Command output:\n$output")
        echo $message
        send_notification "$message"
        sleep $work_duration
        stop_service $input_text1
    else
        echo "Variable1 does not exist."
    fi

    if [ -n "$input_text2" ]; then 
        ((counter++))
        echo "The value of API is: $input_text2"
        start_service $input_text2
        output=$(/usr/local/bin/myria-node --status)
        #    Format the output for sending via Telegram
        message=$(echo -e "Command output:\n$output")
        echo $message
        send_notification "$message"
        sleep $work_duration
        stop_service $input_text2
    else
        echo "Variable2 does not exist."
    fi

    if [ -n "$input_text3" ]; then
        ((counter++))
        echo "The value of API is: $input_text3"
        start_service $input_text3
        output=$(/usr/local/bin/myria-node --status)
        #    Format the output for sending via Telegram
        message=$(echo -e "Command output:\n$output")
        echo $message
        send_notification "$message"
        sleep $work_duration
        stop_service $input_text3
    else
        echo "Variable3 does not exist."
    fi
done
# Exit the script after completing the loop
exit 0


