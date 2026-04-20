#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "========== Mise à jour système =========="
apt-get update -y
apt-get upgrade -y

echo "========== Installation paquets de base =========="
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common \
  unzip \
  git \
  vim \
  nano \
  htop \
  net-tools \
  jq \
  ufw \
  openssh-server

echo "========== Activation SSH =========="
systemctl enable ssh
systemctl restart ssh

echo "========== Configuration SSH =========="
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config

systemctl restart ssh

echo "========== Installation Docker =========="
install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
fi

chmod a+r /etc/apt/keyrings/docker.asc

ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  ${CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "========== Activation Docker =========="
systemctl enable docker
systemctl restart docker

echo "========== Ajout utilisateur vagrant au groupe docker =========="
usermod -aG docker vagrant

echo "========== Firewall minimal =========="
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw --force enable

echo "========== Vérifications =========="
docker --version
docker compose version
systemctl is-active docker
systemctl is-active ssh

echo "========== Fin common.sh =========="