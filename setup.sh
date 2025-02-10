#!/bin/bash
#
# This script reads webapp data (URL & Name) from the JSON file "webApps.json",
# creates webapp shortcuts in the Dock by automating Safari via AppleScript,
# and (optionally) selectively removes only those webapp items from the Dock.
#
# Requirements:
#   - macOS (with Safari)
#   - jq installed (brew install jq)
#   - Accessibility permissions granted to your terminal app for automation
#   - PlistBuddy (included in macOS)
#
# The JSON file should have the following structure:
#
# {
#   "webapps": [
#     {
#       "name": "App Name",
#       "url": "https://example.com"
#     }
#   ]
# }
#
# Usage:
#   ./setup.sh            # Creates the webapp shortcuts only.
#   ./setup.sh remove     # Creates the shortcuts and then removes the created ones.
#

# Function to escape AppleScript string literals (double quotes are doubled)
escape_applescript() {
    printf '%s' "$1" | sed 's/"/""/g'
}

JSON_FILE="webApps.json"
DOCK_PLIST="$HOME/Library/Preferences/com.apple.dock.plist"

# Ensure jq is installed.
if ! command -v jq >/dev/null 2>&1; then
    echo "'jq' command not found! Please install it with 'brew install jq'."
    exit 1
fi

echo "=== Creating WebApp Shortcuts ==="
# Iterate over each webapp entry in the JSON file.
jq -c '.webapps[]' "$JSON_FILE" | while IFS= read -r webapp; do
    # Skip empty entries.
    if [ -z "$webapp" ]; then
        echo "Empty entry found – skipping..."
        continue
    fi

    NAME=$(echo "$webapp" | jq -r '.name')
    URL=$(echo "$webapp" | jq -r '.url')
    
    # Skip entries with missing name or URL.
    if [ -z "$NAME" ] || [ -z "$URL" ]; then
        echo "Empty entry found – skipping..."
        continue
    fi

    # Escape variables for AppleScript.
    ESC_NAME=$(escape_applescript "$NAME")
    ESC_URL=$(escape_applescript "$URL")
    
    # Check if a webapp with the same name already exists in ~/Applications.
    APP_PATH="$HOME/Applications/${NAME}.app"
    if [ -d "$APP_PATH" ]; then
        echo "Webapp '$NAME' already exists at $APP_PATH – skipping..."
        continue
    fi

    echo "Creating webapp: $NAME with URL: $URL"

    osascript <<EOF
        -- Launch Safari and navigate to the provided URL.
        tell application "Safari"
            activate
            open location "$ESC_URL"
        end tell
        delay 5
        tell application "System Events"
            tell process "Safari"
                -- Open the "File" (Ablage) menu and select "Add to Dock..."
                click menu bar item "Ablage" of menu bar 1
                delay 1
                click menu item "Zum Dock hinzufügen …" of menu 1 of menu bar item "Ablage" of menu bar 1
                delay 2
                -- Enter the webapp name and confirm with Enter.
                keystroke "$ESC_NAME"
                delay 0.5
                key code 36
            end tell
        end tell
EOF

    sleep 1
done

# Close all Safari windows and quit Safari.
osascript <<EOF
    tell application "Safari"
        close every window
        quit
    end tell
EOF

echo "=== WebApp Shortcuts Created ==="

# If the first argument is "remove", then remove the created webapp Dock items.
if [ "$1" == "remove" ]; then
    echo "=== Removing Created WebApp Dock Items ==="
    
    # Read the webapp names from JSON into an array (preserving spaces).
    WEBAPP_NAMES=()
    while IFS= read -r line; do
        WEBAPP_NAMES+=("$line")
    done < <(jq -r '.webapps[] | .name' "$JSON_FILE")
    
    for name in "${WEBAPP_NAMES[@]}"; do
        if [ -z "$name" ]; then
            continue
        fi
        echo "Checking for Dock item: $name"
        # Count the number of persistent-app items in the Dock plist.
        count=$(/usr/libexec/PlistBuddy -c "Print persistent-apps" "$DOCK_PLIST" 2>/dev/null | grep -c "Dict")
        # Iterate backwards so that deletion does not affect subsequent indices.
        for (( i=count-1; i>=0; i-- )); do
            label=$(/usr/libexec/PlistBuddy -c "Print persistent-apps:$i:tile-data:file-label" "$DOCK_PLIST" 2>/dev/null)
            if [ "$label" == "$name" ]; then
                echo "Removing Dock item: $name (index $i)"
                /usr/libexec/PlistBuddy -c "Delete persistent-apps:$i" "$DOCK_PLIST"
            fi
        done
    done

    # Restart the Dock to apply changes.
    killall Dock

    echo "=== All Created Webapp Dock Items Have Been Removed ==="
fi
