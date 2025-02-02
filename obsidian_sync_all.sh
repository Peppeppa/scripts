#!/bin/bash

# Parent-Verzeichnis, in dem die Vaults gespeichert werden sollen
PARENT_DIR="$HOME/git"

# Liste der Vaults mit ihren Git-Repository-URLs
declare -A VAULTS
VAULTS["obsidian.dokumentation"]="git@github.com:Peppeppa/obsidian.dokumentation.git"
VAULTS["obsidian.journal"]="git@github.com:Peppeppa/obsidian.journal.git"
VAULTS["obsidian.notes"]="git@github.com:Peppeppa/obsidian.notes.git"

# Zeitstempel für die Commit-Message
COMMIT_MESSAGE="Automatische Aktualisierung am $(date +'%Y-%m-%d %H:%M:%S')"

# Funktion zum Initialisieren der Repositories
init_vaults() {
    echo "Starte Initialisierung der Vaults..."

    # Überprüfe, ob das Parent-Verzeichnis existiert, wenn nicht, erstelle es
    if [ ! -d "$PARENT_DIR" ]; then
        echo "Erstelle Verzeichnis: $PARENT_DIR"
        mkdir -p "$PARENT_DIR"
    fi

    # Klone alle Vaults
    for VAULT in "${!VAULTS[@]}"; do
        VAULT_PATH="$PARENT_DIR/$VAULT"
        REPO_URL="${VAULTS[$VAULT]}"

        if [ ! -d "$VAULT_PATH" ]; then
            echo "Klone $VAULT nach $VAULT_PATH..."
            git clone "$REPO_URL" "$VAULT_PATH"
        else
            echo "$VAULT existiert bereits unter $VAULT_PATH, überspringe..."
        fi
    done

    echo "Initialisierung abgeschlossen!"
}

# Funktion zur Synchronisation eines Vaults
sync_vault() {
    local VAULT_PATH="$PARENT_DIR/$1"
    local REPO_URL="$2"

    if [ -d "$VAULT_PATH" ]; then
        echo "Synchronisiere Vault: $VAULT_PATH"
        cd "$VAULT_PATH" || { echo "Fehler: Pfad $VAULT_PATH nicht gefunden."; return; }

        git pull origin main
        git add .
        git commit -m "$COMMIT_MESSAGE"
        git push origin main

        echo "Vault $1 erfolgreich synchronisiert!"
    else
        echo "Fehler: Vault $1 nicht gefunden. Führe './sync_all_obsidian.sh -init' aus."
    fi
}

# Hauptprogramm
if [ "$1" == "-init" ]; then
    init_vaults
else
    echo "Starte Synchronisation aller Vaults..."
    for VAULT in "${!VAULTS[@]}"; do
        sync_vault "$VAULT" "${VAULTS[$VAULT]}"
    done
    echo "Alle Vaults wurden erfolgreich synchronisiert!"
fi
