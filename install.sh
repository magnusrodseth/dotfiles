#!/bin/zsh

# List of scripts or directories containing scripts
items=(
    "zsh"
    # ... add more scripts or directories here
)

# Loop through the list
for item in $items; do
    # Check if the item is a directory
    if [[ -d $item ]]; then
        # If it's a directory, make all files inside executable
        for file in "$item"/*; do
            chmod +x "$file"
        done
    elif [[ -f $item ]]; then
        # If it's a file, make the file executable
        chmod +x "$item"
    fi
done

echo "Permission changes complete."
