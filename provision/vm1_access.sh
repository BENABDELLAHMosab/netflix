#!/usr/bin/env bash
set -e

echo "========== Configuration VM1 Access & Presentation Layer =========="

# --- Firewall ---
ufw allow 80/tcp                                          # HTTP public
ufw allow 443/tcp                                         # HTTPS public
ufw allow from 10.10.10.15 to any port 9100 proto tcp    # Node Exporter → Prometheus (VM5)

# --- Répertoire de travail ---
mkdir -p /opt/netflix/access
chown -R vagrant:vagrant /opt/netflix

# --- Docker : Frontend (Nginx + reverse proxy) ---
# TODO: Remplacer l'image ci-dessous par l'image réelle publiée sur DockerHub par votre équipe
#       Format attendu : <dockerhub-user>/netflix-frontend:latest
FRONTEND_IMAGE="nginx:alpine"   # Image de test — à remplacer par l'image finale

echo "========== Pull image Frontend =========="
docker pull "${FRONTEND_IMAGE}"

echo "========== Démarrage container Frontend =========="
docker run -d \
  --name netflix-frontend \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  "${FRONTEND_IMAGE}"

echo "========== Vérification Frontend =========="
docker ps --filter "name=netflix-frontend"

echo "VM1 Access prête" > /etc/motd