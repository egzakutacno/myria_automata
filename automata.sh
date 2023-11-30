# config.sh

# if you don't have 3 nodes, leave input_text like this   ""  (delete- Your_Node_API)
# telegram_url line - put your BotToken instead xxxxxxxxxxxxxxxxxxxxx (dont delete the word 'bot')
# chatID = your telegram chatid
# if you dont want telegram messages, leave telegram_url as it is

input_text1="Your_Node1_API"
input_text2="Your_Node2_API"
input_text3="Your_Node3_API"
telegram_url="https://api.telegram.org/botxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/sendMessage"
chat_id="xxxxxxxxx"
start_time="07:02"  # Set the desired start time in HH:MM format
work_duration="6h 20m"

# main.sh

# Source the configuration file
# source config.sh
start_command="myria-node --start"
stop_command="myria-node --stop"

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
        echo "Service started successfully with command: $start_command"
        send_notification "Service started successfully with command: $start_command"
    else
        echo "Failed to start service with command: $start_command"
        send_notification "Failed to start service with command: $start_command"
        exit 1
    fi
}

# Function to stop the service with input text
stop_service() {
    local input_text="$1"
    echo "$input_text" | $stop_command

    # Check if the service stopped successfully
    if [ $? -eq 0 ]; then
        echo "Service stopped successfully with command: $stop_command"
        send_notification "Service stopped successfully with command: $stop_command"
    else
        echo "Failed to stop service with command: $stop_command"
        send_notification "Failed to stop service with command: $stop_command"
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

    # work_time = $(($counter * $work_duration))

done
