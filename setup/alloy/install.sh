#!/bin/bash
# Install Grafana Alloy on the Hetzner server
# Run from your LOCAL machine:
#   ./setup/alloy/install.sh <server-ip> <gcloud-rw-api-key>
#
# Uses the same Grafana Cloud account as cenped.

set -euo pipefail

SERVER_IP="${1:?Usage: $0 <server-ip> <gcloud-rw-api-key>}"
API_KEY="${2:?Usage: $0 <server-ip> <gcloud-rw-api-key>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Copying Alloy config to server..."
scp "$SCRIPT_DIR/config.alloy" "appuser@$SERVER_IP:/tmp/config.alloy"

echo "==> Installing Alloy on server..."
ssh "appuser@$SERVER_IP" bash -s <<REMOTE
set -euo pipefail

# Install Alloy if not present
if ! command -v alloy &> /dev/null; then
  echo "==> Adding Grafana APT repository..."
  sudo mkdir -p /etc/apt/keyrings/
  curl -fsSL https://apt.grafana.com/gpg.key | sudo gpg --batch --dearmor -o /etc/apt/keyrings/grafana.gpg
  echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y alloy
else
  echo "==> Alloy already installed"
fi

# Deploy config
echo "==> Deploying Alloy configuration..."
sudo cp /tmp/config.alloy /etc/alloy/config.alloy
rm /tmp/config.alloy

# Set API key in Alloy's environment
echo "==> Configuring GCLOUD_RW_API_KEY..."
sudo mkdir -p /etc/alloy
echo "GCLOUD_RW_API_KEY=$API_KEY" | sudo tee /etc/alloy/environment > /dev/null
sudo chmod 600 /etc/alloy/environment

# Configure systemd to load the environment file
sudo mkdir -p /etc/systemd/system/alloy.service.d
sudo tee /etc/systemd/system/alloy.service.d/override.conf > /dev/null <<EOF
[Service]
EnvironmentFile=/etc/alloy/environment
ExecStart=
ExecStart=/usr/bin/alloy run /etc/alloy/config.alloy --storage.path=/var/lib/alloy/data --stability.level=public-preview
EOF

# Start/restart Alloy
echo "==> Starting Alloy..."
sudo systemctl daemon-reload
sudo systemctl enable alloy
sudo systemctl restart alloy
sleep 3
sudo systemctl status alloy --no-pager

echo ""
echo "==> Alloy installed and running!"
REMOTE

echo ""
echo "Done! Check Grafana Cloud for instance: hetzner-kleer"
echo "  Metrics: probe_success{job=\"kleer/health\"}"
echo "  Logs: {job=\"kleer/app\"}"
