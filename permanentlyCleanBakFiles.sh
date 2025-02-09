#!/usr/bin/env bash

echo "Cleaning up backup (.bak) files and directories..."

# Definiere die Zielverzeichnisse
TARGETS=(~/Library/Preferences ~/Applications)

# Schleife über alle Zielverzeichnisse
for target in "${TARGETS[@]}"; do
  if [ -d "$target" ]; then
    echo "Cleaning in $target"
    # Lösche sowohl Dateien als auch Verzeichnisse, die auf .bak enden
    find "$target" -maxdepth 1 -name "*.bak" -exec rm -rfv {} \;
  else
    echo "Directory $target does not exist."
  fi
done

echo "Cleanup complete."
