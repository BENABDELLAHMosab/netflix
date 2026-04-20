#!/usr/bin/env bash
set -e

echo "========== Configuration VM5 Monitoring & Observability Layer =========="

# --- Firewall ---
ufw allow from 10.10.10.0/24 to any port 9090 proto tcp    # Prometheus UI ← réseau interne uniquement
ufw allow from 10.10.10.0/24 to any port 3000 proto tcp    # Grafana UI ← réseau interne uniquement

# --- Répertoire de travail ---
mkdir -p /opt/netflix/monitor
chown -R vagrant:vagrant /opt/netflix

echo "VM5 Monitor prête" > /etc/motd