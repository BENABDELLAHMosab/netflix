#!/usr/bin/env bash
set -e

echo "========== Configuration VM2 Application Layer =========="

# --- Firewall ---
ufw allow from 10.10.10.11 to any port 3000 proto tcp    # API Backend ← VM1 (Nginx reverse proxy) uniquement
ufw allow from 10.10.10.15 to any port 9100 proto tcp    # Node Exporter → Prometheus (VM5)

# --- Répertoire de travail ---
mkdir -p /opt/netflix/app
chown -R vagrant:vagrant /opt/netflix

# --- Docker : Backend API (Node.js / Express) ---
# TODO: Remplacer l'image ci-dessous par l'image réelle publiée sur DockerHub par votre équipe
#       Format attendu : <dockerhub-user>/netflix-backend:latest
BACKEND_IMAGE="node:18-alpine"  # Image de test — à remplacer par l'image finale

echo "========== Pull image Backend =========="
docker pull "${BACKEND_IMAGE}"

echo "========== Démarrage container Backend =========="
docker run -d \
  --name netflix-backend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e DB_HOST=10.10.10.13 \
  -e DB_PORT=5432 \
  -e MINIO_HOST=10.10.10.14 \
  -e MINIO_PORT=9000 \
  "${BACKEND_IMAGE}" \
  node -e "
    const http = require('http');
    const server = http.createServer((req, res) => {
      res.writeHead(200, {'Content-Type': 'application/json'});
      res.end(JSON.stringify({ status: 'ok', service: 'netflix-backend', message: 'Image de test — remplacer par image finale' }));
    });
    server.listen(3000, () => console.log('Backend test running on :3000'));
  "

echo "========== Vérification Backend =========="
docker ps --filter "name=netflix-backend"

echo "VM2 App prête" > /etc/motd