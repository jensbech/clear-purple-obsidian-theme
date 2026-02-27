#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="Clear Purple"

read -rp "Vault path: " VAULT
VAULT="${VAULT/#\~/$HOME}"
DEST="$VAULT/.obsidian/themes/$THEME_NAME"

if [[ ! -d "$VAULT/.obsidian" ]]; then
  echo "Error: no Obsidian vault found at '$VAULT'" >&2
  exit 1
fi

mkdir -p "$DEST"
cp theme.css manifest.json "$DEST/"
echo "Installed to $DEST"
