#!/bin/bash

# pfad repoordner
PARENT_DIR="$HOME/git"

# liste vault + git urls
declare -A VAULTS
VAULTS["obsidian.journal"]="git@github.com:Peppeppa/obsidian.journal.git"
VAULTS["obsidian.notes"]="git@github.com:Peppeppa/obsidian.notes.git"
VAULTS["obsidian.dokumentation"]="git@github.com:Peppeppa/obsidian.dokumentation.git"

# commit message zeitstempel
COMMIT_MESSAGE="Automatische Aktualisierung am $(date +'%Y-%m-%d %H:%M:%S')"

# FUNKTION - initialisierung repos
init_vaults() {
    echo "Starte Initialisierung"

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

# Funktion: Cronjob einrichten

setup_cronjob() {
    CRON_CMD="*/30 * * * * $PWD/sync_all_obsidian.sh >> $HOME/obsidian_sync.log 2>&1"
    
    # Aktuelle Crontab auslesen, aber Fehler unterdrücken, falls noch keine existiert
    CURRENT_CRON=$(crontab -l 2>/dev/null)

    # Prüfen, ob bereits ein Cronjob mit 'sync_all_obsidian.sh' existiert
    if echo "$CURRENT_CRON" | grep -q "sync_all_obsidian.sh"; then
        echo "Ein bestehender Cronjob für sync_all_obsidian.sh wurde gefunden. Er wird überschrieben..."
        # Alten Cronjob entfernen und neuen hinzufügen
        (echo "$CURRENT_CRON" | grep -v "sync_all_obsidian.sh"; echo "$CRON_CMD") | crontab -
    else
        echo "Kein bestehender Cronjob gefunden. Ein neuer wird hinzugefügt..."
        (echo "$CURRENT_CRON"; echo "$CRON_CMD") | crontab -
    fi

    echo "Cronjob wurde eingerichtet! Synchronisation erfolgt alle 30 Minuten."
}

# Hauptprogramm
case "$1" in
    -init)
        init_vaults
        ;;
    -cron)
        setup_cronjob
        ;;
    *)
        echo "Starte Synchronisation aller Vaults..."
        for VAULT in "${!VAULTS[@]}"; do
            sync_vault "$VAULT" "${VAULTS[$VAULT]}"
        done
        echo "Alle Vaults wurden erfolgreich synchronisiert!"
        ;;
esac
