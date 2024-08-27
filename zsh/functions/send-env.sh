#!/bin/zsh

send-env() {
    export NODE_NO_WARNINGS=1

    # Check if input is from a pipe or stdin
    if [ -t 0 ]; then
        echo "Usage: cat .env | send-env"
        return 1
    fi

    # Check if Bitwarden CLI is logged in
    local bw_status
    bw_status=$(bw status | jq -r '.status')

    if [[ "$bw_status" == "unauthenticated" ]]; then
        echo "Bitwarden CLI is not logged in. Logging in..."
        bw login
        if [[ $? -ne 0 ]]; then
            echo "Login failed. Please check your credentials."
            return 1
        fi
    fi

    # Check if the vault is locked and provide instructions if necessary
    bw_status=$(bw status | jq -r '.status')

    if [[ "$bw_status" == "locked" ]]; then
        echo "The Bitwarden vault is locked."
        echo "Please run the following command to unlock it and set the session key:"
        echo
        echo 'export BW_SESSION=$(bw unlock --raw)'
        echo
        echo "Then, re-run this script."
        return 1
    fi

    # Read the input from stdin
    local env_content
    env_content=$(cat)

    # Initialize variables
    local chunk=""
    local chunk_counter=1
    local max_length=1000
    local result=""

    send_chunk() {
        local chunk_data="$1"
        local chunk_number="$2"
        local send_name=".env"
        
        if [ $chunk_counter -gt 1 ]; then
            send_name=".env - Part ${chunk_number}"
        fi

        echo "Sending chunk ${chunk_number}..."

        # Use the simpler bw send command to create the Send
        local send_output
        send_output=$(bw send -n "$send_name" -d 7 "$chunk_data" 2>&1)
        local exit_code=$?

        if [ $exit_code -eq 0 ]; then
            local access_url
            access_url=$(echo "$send_output" | jq -r '.accessUrl' 2>&1)
            local jq_exit_code=$?

            if [ $jq_exit_code -ne 0 ]; then
                echo "jq error processing send_output for chunk ${chunk_number}:"
                echo "$access_url"  # This contains the jq error message
            elif [ "$access_url" == "null" ] || [ -z "$access_url" ]; then
                echo "Failed to retrieve accessUrl for chunk ${chunk_number}."
                echo "send_output was:"
                echo "$send_output"
            else
                result+="$access_url"$'\n'
            fi
        else
            echo "Error sending chunk ${chunk_number}:"
            echo "$send_output"
        fi
    }

    # Process the env content
    local current_length=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Ignore lines that start with '#', as these are comments in an env file
        if [[ "$line" =~ ^# ]]; then
            continue
        fi

        local line_length=${#line}

        if (( current_length + line_length + 1 > max_length )); then
            send_chunk "$chunk" "$chunk_counter"
            ((chunk_counter++))
            chunk=""
            current_length=0
        fi

        chunk+="$line"$'\n'
        ((current_length += line_length + 1))
    done <<< "$env_content"

    # Send the last chunk if it's not empty
    if [[ -n "$chunk" ]]; then
        send_chunk "$chunk" "$chunk_counter"
    fi

    # Copy the result to clipboard
    echo -n "$result" | pbcopy

    echo "All chunks sent. Links copied to clipboard:"
    echo "$result"
}

