#!/bin/zsh

send-env() {
    # Check if input is from a pipe or stdin
    if [ -t 0 ]; then
        echo "Usage: cat .env | send-env"
        return 1
    fi

    # Check if 1Password CLI is signed in
    op_status=$(op account list --format=json 2>/dev/null)

    if [ -z "$op_status" ]; then
        echo "1Password CLI is not signed in. Please sign in first."
        echo "Run: eval \$(op signin)"
        return 1
    fi

    # Read the input from stdin
    local env_content
    env_content=$(cat)

    # Create a temporary JSON file for the template
    tmp_template=$(mktemp)
    tmp_modified_template=$(mktemp)
    tmp_env_content=$(mktemp)

    # Get the Secure Note template (suppress overwrite prompt)
    op item template get "Secure Note" --out-file "$tmp_template" -f

    if [ $? -ne 0 ]; then
        echo "Error getting Secure Note template."
        rm "$tmp_template"
        return 1
    fi

    # Write env_content to a temporary file
    echo "$env_content" > "$tmp_env_content"

    # Modify the template to include your .env content
    jq --rawfile content "$tmp_env_content" '(.fields[] | select(.id=="notesPlain")).value = $content' "$tmp_template" > "$tmp_modified_template"

    if [ $? -ne 0 ]; then
        echo "Error modifying the template."
        rm "$tmp_template" "$tmp_modified_template" "$tmp_env_content"
        return 1
    fi

    item_title="[$(basename "$(pwd)")] - .env - $(date +'%d.%m.%Y')"

    # Close stdin before op item create
    exec </dev/null

    # Create the item in 1Password using the modified template
    item_create_output=$(op item create --title "$item_title" --vault "Environment Variables" --template "$tmp_modified_template" --format=json)

    # Clean up temporary files
    rm "$tmp_template" "$tmp_modified_template" "$tmp_env_content"

    if [ $? -ne 0 ]; then
        echo "Error creating the item in 1Password."
        echo "$item_create_output"
        return 1
    fi

    # Extract the item ID from the output
    item_id=$(echo "$item_create_output" | jq -r '.id')

    if [ -z "$item_id" ] || [ "$item_id" = "null" ]; then
        echo "Failed to get item ID."
        return 1
    fi

    # Generate a shareable link
    share_output=$(op item share "$item_id" --vault "Environment Variables")

    if [ $? -ne 0 ]; then
        echo "Error sharing the item."
        echo "$share_output"
        return 1
    fi

    # Extract the share link
    share_link=$(echo "$share_output" | grep -o 'https://share.*')

    if [ -z "$share_link" ]; then
        echo "Failed to retrieve share link."
        echo "$share_output"
        return 1
    fi

    # Copy the link to clipboard
    echo -n "$share_link" | pbcopy

    echo "Link copied to clipboard:"
    echo "$share_link"
}
