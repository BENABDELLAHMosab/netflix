#!/usr/bin/env bash
set -e

echo "========== Configuration VM3 Relational Data Layer =========="

# --- Firewall ---
ufw allow from 10.10.10.12 to any port 5432 proto tcp    # PostgreSQL ← Backend VM2 uniquement
ufw allow from 10.10.10.15 to any port 9100 proto tcp    # Node Exporter → Prometheus (VM5)

# --- Répertoire de travail ---
mkdir -p /opt/netflix/db
chown -R vagrant:vagrant /opt/netflix

echo "VM3 DB prête" > /etc/motd