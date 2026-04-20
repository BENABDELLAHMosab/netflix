#!/usr/bin/env bash
set -e

echo "========== Configuration VM4 Object Storage Layer =========="

# --- Firewall ---
ufw allow from 10.10.10.12 to any port 9000 proto tcp    # MinIO API ← Backend VM2 uniquement
ufw allow from 10.10.10.12 to any port 9001 proto tcp    # MinIO Console ← Backend VM2 uniquement
ufw allow from 10.10.10.15 to any port 9100 proto tcp    # Node Exporter → Prometheus (VM5)
ufw allow from 10.10.10.15 to any port 9000 proto tcp    # MinIO Metrics → Prometheus (VM5)

# --- Répertoire de travail ---
mkdir -p /opt/netflix/object
mkdir -p "$HOME/minio/data"
mkdir -p "$HOME/minio/certs"
chown -R vagrant:vagrant /opt/netflix

# --- MinIO : stopper et supprimer le container s'il existe déjà ---
echo "========== Nettoyage container MinIO existant =========="
if docker ps -a --format '{{.Names}}' | grep -q "^aistor-server$"; then
  echo "Container 'aistor-server' trouvé — suppression..."
  docker stop aistor-server || true
  docker rm   aistor-server || true
else
  echo "Aucun container existant, démarrage propre."
fi

# --- Démarrage MinIO ---
echo "========== Pull image MinIO =========="
docker pull quay.io/minio/aistor/minio:latest

echo "========== Démarrage container MinIO =========="
docker run -dt \
  -p 9000:9000 \
  -p 9001:9001 \
  -v "$HOME/minio/data:/mnt/data" \
  --name "aistor-server" \
  --restart unless-stopped \
  quay.io/minio/aistor/minio:latest \
  minio server /mnt/data

echo "========== Vérification MinIO =========="
sleep 3
docker ps --filter "name=aistor-server"
docker logs aistor-server 2>&1 | tail -20

echo "VM4 Object prête" > /etc/motd