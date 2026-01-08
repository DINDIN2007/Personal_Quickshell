#!/bin/bash
# list_apps.sh

echo "["
first=true

# Loop through common application directories
for file in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do
    [ -e "$file" ] || continue
    
    # Extract Name and Exec (basic parsing)
    name=$(grep -m 1 "^Name=" "$file" | cut -d= -f2-)
    exec_cmd=$(grep -m 1 "^Exec=" "$file" | cut -d= -f2- | cut -d'%' -f1) # Remove %u/%f args
    icon=$(grep -m 1 "^Icon=" "$file" | cut -d= -f2-)

    # Skip invalid entries
    if [ -z "$name" ] || [ -z "$exec_cmd" ]; then continue; fi

    # Handle comma logic for JSON
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi

    # Output JSON object (using jq would be safer, but manual for zero-dep)
    # Escape quotes in names
    safe_name=$(echo "$name" | sed 's/"/\\"/g')
    echo "  {\"name\": \"$safe_name\", \"exec\": \"$exec_cmd\", \"icon\": \"$icon\"}"
done

echo "]"