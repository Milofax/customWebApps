#!/bin/bash
#
# Dieses Skript liest Webapp-Daten (URL & Name) aus der JSON-Datei "webApps.json"
# und erstellt per AppleScript für jede Webapp einen entsprechenden Eintrag im Dock.
# Dabei werden URLs und Namen, die Sonderzeichen enthalten, korrekt escaped.
#
# Voraussetzung: jq muss installiert sein (Installation via "brew install jq").

# Escape-Funktion für AppleScript-Strings:
# In AppleScript müssen doppelte Anführungszeichen innerhalb eines String-Literals verdoppelt werden.
escape_applescript() {
    printf '%s' "$1" | sed 's/"/""/g'
}

JSON_FILE="webApps.json"

# Prüfe, ob jq verfügbar ist
if ! command -v jq >/dev/null 2>&1; then
    echo "'jq' command not found! Bitte installiere es mit 'brew install jq'."
    exit 1
fi

# Iteriere über jeden Eintrag in der JSON-Datei mit einer while-Schleife, um Probleme mit Zeilenumbrüchen zu vermeiden.
jq -c '.webapps[]' "$JSON_FILE" | while IFS= read -r webapp; do
    # Falls ein Eintrag leer ist, überspringen wir diesen.
    if [ -z "$webapp" ]; then
        echo "Leerer Eintrag gefunden – überspringe..."
        continue
    fi

    NAME=$(echo "$webapp" | jq -r '.name')
    URL=$(echo "$webapp" | jq -r '.url')
    
    # Falls Name oder URL leer sind, überspringen wir diesen Eintrag.
    if [ -z "$NAME" ] || [ -z "$URL" ]; then
        echo "Leerer Eintrag gefunden – überspringe..."
        continue
    fi

    # Escape von NAME und URL für AppleScript:
    ESC_NAME=$(escape_applescript "$NAME")
    ESC_URL=$(escape_applescript "$URL")
    
    APP_PATH="$HOME/Applications/${NAME}.app"
    if [ -d "$APP_PATH" ]; then
        echo "Webapp '$NAME' existiert bereits unter $APP_PATH – überspringe..."
        continue
    fi

    echo "Erstelle Webapp: $NAME mit URL: $URL"

    osascript <<EOF
-- Starte Safari und navigiere zur URL (mit escaped URL)
tell application "Safari"
    activate
    open location "$ESC_URL"
end tell
delay 5
tell application "System Events"
    tell process "Safari"
        -- Öffne das Menü "Ablage" und wähle "Zum Dock hinzufügen …"
        click menu bar item "Ablage" of menu bar 1
        delay 1
        click menu item "Zum Dock hinzufügen …" of menu 1 of menu bar item "Ablage" of menu bar 1
        delay 2
        -- Tippe den escaped Webapp-Namen ein
        keystroke "$ESC_NAME"
        delay 0.5
        key code 36
    end tell
end tell
EOF

    sleep 1
done

# Beende Safari vollständig
osascript <<EOF
tell application "Safari" to quit
EOF

echo "Alle Webapps wurden erstellt und Safari wurde geschlossen."

echo "Alle Webapps wurden erstellt und alle Safari-Fenster geschlossen."
