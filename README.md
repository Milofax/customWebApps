# WebApp Auto Creator

WebApp Auto Creator is a macOS automation project that creates web application shortcuts (i.e., “Apps”) by reading entries from a JSON file and using AppleScript to control Safari. This allows you to quickly add your favorite web apps to the Dock.

## How It Works

-  The script (`setup.sh`) parses a JSON file named `webApps.json` containing an array of web apps.
-  Each entry is expected to have two keys: `name` and `url`.
-  The script uses `jq` for JSON parsing and ensures that any special characters in URLs or names are properly escaped for AppleScript.
-  Safari is launched, navigated to the URL, and then controlled via simulated keyboard input and menu clicks to add the web app shortcut.
-  Finally, Safari’s windows are closed and Safari is quit completely.

## Prerequisites
jq has to be installed. On the mac, use `brew install jq`.
