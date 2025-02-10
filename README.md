# WebApp Auto Creator

Using modern window managers in Mac OS like [aerospace](https://nikitabobko.github.io/AeroSpace) restrict an opening browser window to one workspace, if you defined it. I wanted to be more flexible with my different Websites and contained Services and Apps.

WebApp Auto Creator is a macOS automation project that creates web application shortcuts (i.e. “Apps”) in the Dock by reading entries from a JSON file and using AppleScript to control Safari. Optionally, the script can also remove the created webapp items from the Dock.

## How It Works

-  The script (`setup.sh`) reads webapp data from a JSON file named `webApps.json`. Each entry must include two keys: `name` and `url`.
-  For each entry, the script uses `jq` to parse the JSON and escapes special characters in the `name` and `url` for safe insertion into an AppleScript block.
-  The AppleScript in the script automates Safari—it opens the given URL, interacts with the menu (in German, the script uses “Ablage” and “Zum Dock hinzufügen …”) and simulates keystrokes to add the webapp shortcut to the Dock.
-  After all webapps are processed, Safari is closed (all windows are closed and Safari quits).
-  Optionally, if you run the script with the argument `remove`, it will read the webapp names from the JSON file and, using PlistBuddy, remove from the Dock any persistent app item whose file label matches one of the webapp names. The Dock is then restarted to apply these changes.

## Prerequisites

-  **macOS with Safari:** The script automates Safari to create the webapp shortcuts.
-  **jq:** A lightweight and flexible command-line JSON processor. Install via Homebrew:
  ```bash
  brew install jq
