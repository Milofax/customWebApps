#!/usr/bin/env bash

# Quell- und Zielverzeichnisse für Preferences und Applications
PREFS_SRC="Preferences"
PREFS_TARGET=~/Library/Preferences

APPS_SRC="Applications"
APPS_TARGET=~/Applications

echo "========================================"
echo "Linking preference files..."

# Sicherung bzw. Backup der vorhandenen plist-Dateien, sofern diese keine Symlink sind
for file in "$PREFS_SRC"/*.plist; do
  filename=$(basename "$file")
  target_file="$PREFS_TARGET/$filename"

  if [ -e "$target_file" ]; then
    if [ -L "$target_file" ]; then
      echo "Symlink für $filename existiert bereits. Überspringe Backup."
    else
      echo "Datei $filename existiert bereits."
      echo "Sichere $target_file nach ${target_file}.bak"
      mv "$target_file" "${target_file}.bak"
    fi
  fi
done

# Stow für Preferences ausführen
stow -t "$PREFS_TARGET" Preferences

echo "========================================"
echo "Linking Applications..."

# Sicherung bzw. Backup der vorhandenen .app-Verzeichnisse, sofern diese keine Symlink sind
for app in "$APPS_SRC"/*.app; do
  appname=$(basename "$app")
  target_app="$APPS_TARGET/$appname"

  if [ -e "$target_app" ]; then
    if [ -L "$target_app" ]; then
      echo "Symlink für $appname existiert bereits. Überspringe Backup."
    else
      echo "Application $appname existiert bereits."
      echo "Sichere $target_app nach ${target_app}.bak"
      mv "$target_app" "${target_app}.bak"
    fi
  fi
done

# Stow für Applications ausführen
stow -t "$APPS_TARGET" Applications

echo "========================================"
echo "Setup abgeschlossen."
