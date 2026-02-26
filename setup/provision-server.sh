#!/bin/bash
# Server provisioning script for Hetzner VPS
# Run this from your LOCAL machine (not on the server)
# Usage: ./setup/provision-server.sh <server-ip> [ssh-public-key-path]
#
# Prerequisites:
#   - Root SSH access to the server (via Hetzner SSH key setup)
#   - SSH public key to authorize for appuser (defaults to ~/.ssh/id_ed25519.pub)

set -euo pipefail

SERVER_IP="${1:?Usage: $0 <server-ip> [ssh-public-key-path]}"
SSH_KEY_PATH="${2:-$HOME/.ssh/id_ed25519.pub}"

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "Error: SSH public key not found at $SSH_KEY_PATH"
  exit 1
fi

SSH_PUBLIC_KEY=$(cat "$SSH_KEY_PATH")

echo "Provisioning server at $SERVER_IP..."
echo "Using SSH key: $SSH_KEY_PATH"

ssh -o StrictHostKeyChecking=accept-new "root@$SERVER_IP" bash -s <<REMOTE
set -euo pipefail

echo "==> Creating appuser..."
adduser --disabled-password --gecos "" appuser || echo "User appuser already exists"

echo "==> Setting up SSH key for appuser..."
mkdir -p /home/appuser/.ssh
echo "$SSH_PUBLIC_KEY" >> /home/appuser/.ssh/authorized_keys
sort -u /home/appuser/.ssh/authorized_keys -o /home/appuser/.ssh/authorized_keys
chown -R appuser:appuser /home/appuser/.ssh
chmod 700 /home/appuser/.ssh
chmod 600 /home/appuser/.ssh/authorized_keys

echo "==> Granting sudo without password..."
echo "appuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appuser
chmod 440 /etc/sudoers.d/appuser

echo "==> Configuring firewall (SSH, HTTP, HTTPS)..."
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "==> Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
else
  echo "Docker already installed"
fi

echo "==> Adding appuser to docker group..."
usermod -aG docker appuser

echo "==> Server provisioning complete!"
echo "    User: appuser"
echo "    Firewall: SSH, HTTP, HTTPS"
echo "    Docker: installed"
REMOTE

echo ""
echo "==> Testing SSH as appuser..."
ssh -o StrictHostKeyChecking=accept-new "appuser@$SERVER_IP" "echo 'SSH OK' && docker --version"

echo ""
echo "Server ready! Next steps:"
echo "  1. Set SERVER_IP=$SERVER_IP in your website.env"
echo "  2. Run: kamal setup -d qa"
