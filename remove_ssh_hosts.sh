#!/bin/bash

# IPs der Server
servers=("10.1.10.211" "10.1.10.212" "10.1.10.213")

# known_hosts Datei
known_hosts="$HOME/.ssh/known_hosts"

for server in "${servers[@]}"; do
    # Entferne den Eintrag für den Server aus der known_hosts-Datei
    ssh-keygen -R "$server" -f "$known_hosts"
done

echo "Einträge wurden aus der known_hosts entfernt."

