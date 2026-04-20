# 🎬 Guide de gestion des VMs — Netflix Cloud Project

> Toutes les commandes ci-dessous s'exécutent depuis **PowerShell Windows**
> dans le dossier du projet : `C:\Users\Pro\OneDrive\Desktop\netflix-cloud-project`

---

## 🗺️ Carte du réseau

| VM | Rôle | IP privée | Ports exposés (hôte) |
|----|------|-----------|----------------------|
| `vm1-access` | Frontend / Nginx / Reverse Proxy | `10.10.10.11` | HTTP→8080, HTTPS→8443, SSH→2221 |
| `vm2-app` | Backend API Node.js/Express | `10.10.10.12` | — (interne uniquement) |
| `vm3-db` | Base de données PostgreSQL | `10.10.10.13` | — (interne uniquement) |
| `vm4-object` | Stockage objet MinIO | `10.10.10.14` | — (interne uniquement) |
| `vm5-monitor` | Prometheus + Grafana | `10.10.10.15` | — (interne uniquement) |

---

## ▶️ Démarrage

```powershell
# Démarrer toutes les VMs
vagrant up

# Démarrer une seule VM
vagrant up vm1-access
vagrant up vm2-app
vagrant up vm3-db
vagrant up vm4-object
vagrant up vm5-monitor
```

---

## ⏹️ Arrêt

```powershell
# Arrêter toutes les VMs (état sauvegardé sur disque)
vagrant halt

# Arrêter une seule VM
vagrant halt vm1-access

# Mettre en pause (suspend / hibernate)
vagrant suspend
vagrant suspend vm2-app

# Reprendre depuis la pause
vagrant resume
vagrant resume vm2-app
```

---

## 🔄 Redémarrage

```powershell
# Redémarrer toutes les VMs
vagrant reload

# Redémarrer une seule VM
vagrant reload vm1-access

# Redémarrer ET ré-exécuter les scripts de provision
vagrant reload --provision vm1-access
```

---

## 🔵 Statut

```powershell
# Voir l'état de toutes les VMs
vagrant status

# Voir l'état global (toutes les VMs Vagrant sur la machine)
vagrant global-status
```

---

## 🔑 Connexion SSH

```powershell
# Se connecter à une VM
vagrant ssh vm1-access
vagrant ssh vm2-app
vagrant ssh vm3-db
vagrant ssh vm4-object
vagrant ssh vm5-monitor

# Exécuter une commande sans entrer dans la VM
vagrant ssh vm1-access -c "docker ps"
vagrant ssh vm2-app    -c "curl http://localhost:3000"
vagrant ssh vm3-db     -c "sudo ufw status"
```

> ⚠️ `vagrant ssh` ne fonctionne **que depuis PowerShell Windows**, jamais depuis l'intérieur d'une VM.

---

## 🐳 Gestion Docker (depuis l'intérieur d'une VM)

```bash
# Voir les containers actifs
docker ps

# Voir tous les containers (y compris arrêtés)
docker ps -a

# Voir les logs d'un container
docker logs netflix-frontend
docker logs netflix-backend

# Suivre les logs en temps réel
docker logs -f netflix-backend

# Redémarrer un container
docker restart netflix-frontend

# Arrêter un container
docker stop netflix-backend

# Supprimer un container
docker rm netflix-backend

# Mettre à jour l'image (pull + recréer) :
docker pull <dockerhub-user>/netflix-frontend:latest
docker stop netflix-frontend && docker rm netflix-frontend
docker run -d --name netflix-frontend --restart unless-stopped -p 80:80 <image>
```

---

## 🔥 Firewall UFW (depuis l'intérieur d'une VM)

```bash
# Voir les règles actives
sudo ufw status verbose

# Ajouter une règle
sudo ufw allow from 10.10.10.11 to any port 3000 proto tcp

# Supprimer une règle
sudo ufw delete allow from 10.10.10.11 to any port 3000 proto tcp

# Recharger
sudo ufw reload
```

---

## 🌐 Tests de connectivité

```powershell
# Tester la connectivité réseau depuis VM1 vers les autres
vagrant ssh vm1-access -c "ping -c 2 10.10.10.12"   # VM2
vagrant ssh vm1-access -c "ping -c 2 10.10.10.13"   # VM3
vagrant ssh vm1-access -c "ping -c 2 10.10.10.14"   # VM4
vagrant ssh vm1-access -c "ping -c 2 10.10.10.15"   # VM5

# Tester l'API Backend depuis VM1 (comme le ferait Nginx)
vagrant ssh vm1-access -c "curl http://10.10.10.12:3000"

# Tester le Frontend depuis le navigateur Windows
# http://localhost:8080
```

---

## 🔁 Mise à jour / Re-provision

```powershell
# Ré-exécuter uniquement les scripts de provision (sans redémarrer)
vagrant provision vm1-access
vagrant provision vm2-app

# Ré-exécuter provision sur toutes les VMs
vagrant provision

# Redémarrer + re-provision (modification du Vagrantfile ou scripts)
vagrant reload --provision
```

---

## 🗑️ Destruction / Réinitialisation

```powershell
# Détruire toutes les VMs (irréversible — les données sont perdues)
vagrant destroy -f

# Détruire une seule VM
vagrant destroy -f vm3-db

# Repartir de zéro (détruire + recréer)
vagrant destroy -f && vagrant up
```

---

## 🔍 Diagnostic rapide

```powershell
# Vérifier que Docker tourne sur toutes les VMs
vagrant ssh vm1-access -c "systemctl is-active docker"
vagrant ssh vm2-app    -c "systemctl is-active docker"
vagrant ssh vm3-db     -c "systemctl is-active docker"
vagrant ssh vm4-object -c "systemctl is-active docker"
vagrant ssh vm5-monitor -c "systemctl is-active docker"

# Vérifier les containers sur VM1 et VM2
vagrant ssh vm1-access -c "docker ps"
vagrant ssh vm2-app    -c "docker ps"

# Voir l'utilisation des ressources dans une VM
vagrant ssh vm5-monitor -c "htop"   # (quitter avec q)
vagrant ssh vm5-monitor -c "df -h"  # espace disque
vagrant ssh vm5-monitor -c "free -h" # mémoire RAM
```

---

## 📦 Gestion des boxes Vagrant

```powershell
# Lister les boxes installées
vagrant box list

# Mettre à jour une box (nouvelle version)
vagrant box update --box generic/debian12

# Supprimer une ancienne version de box
vagrant box prune

# Supprimer une box spécifique
vagrant box remove generic/debian12
```

---

## 🚀 Workflow quotidien typique

```powershell
# Matin : démarrer l'environnement
cd C:\Users\Pro\OneDrive\Desktop\netflix-cloud-project
vagrant up

# Développement : accéder à une VM
vagrant ssh vm2-app

# Mettre à jour l'image d'un service (quand collègue pousse sur DockerHub)
vagrant ssh vm2-app -c "docker pull <user>/netflix-backend:latest && docker restart netflix-backend"

# Soir : sauvegarder l'état et éteindre
vagrant halt
```
