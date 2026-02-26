#!/bin/bash
# Install PostgreSQL backup script and cron job on the Hetzner server
# Run from your LOCAL machine:
#   ./setup/backups/install.sh <server-ip> <aws-access-key-id> <aws-secret-access-key>
#
# Backs up eventer_production daily at 3am UTC.
# Local retention: 30 days. S3 retention: 365 days (s3://backups-kleer/eventer/).

set -euo pipefail

SERVER_IP="${1:?Usage: $0 <server-ip> <aws-access-key-id> <aws-secret-access-key>}"
AWS_KEY="${2:?Usage: $0 <server-ip> <aws-access-key-id> <aws-secret-access-key>}"
AWS_SECRET="${3:?Usage: $0 <server-ip> <aws-access-key-id> <aws-secret-access-key>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Copying backup script to server..."
scp "$SCRIPT_DIR/backup-postgres.sh" "appuser@$SERVER_IP:/tmp/backup-postgres.sh"

echo "==> Installing on server..."
ssh "appuser@$SERVER_IP" bash -s <<REMOTE
set -euo pipefail

# Install AWS CLI if not present
if [ ! -f "\$HOME/.local/bin/aws" ]; then
  echo "==> Installing AWS CLI..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq python3-pip
  pip3 install awscli --user --break-system-packages --quiet
else
  echo "==> AWS CLI already installed"
fi

# Configure AWS credentials
echo "==> Configuring AWS credentials..."
mkdir -p "\$HOME/.aws"
cat > "\$HOME/.aws/credentials" <<EOF
[default]
aws_access_key_id = $AWS_KEY
aws_secret_access_key = $AWS_SECRET
EOF
cat > "\$HOME/.aws/config" <<EOF
[default]
region = us-east-1
EOF
chmod 600 "\$HOME/.aws/credentials"

# Install backup script
echo "==> Installing backup script..."
mkdir -p "\$HOME/backups"
cp /tmp/backup-postgres.sh "\$HOME/backups/backup-postgres.sh"
chmod +x "\$HOME/backups/backup-postgres.sh"
rm /tmp/backup-postgres.sh

# Set up cron job (idempotent)
CRON_LINE="0 3 * * * \$HOME/backups/backup-postgres.sh >> \$HOME/backups/backup.log 2>&1"
(crontab -l 2>/dev/null | grep -v "backup-postgres.sh"; echo "\$CRON_LINE") | crontab -

echo "==> Running test backup..."
"\$HOME/backups/backup-postgres.sh"

echo ""
echo "==> Backup setup complete!"
echo "    Script: ~/backups/backup-postgres.sh"
echo "    Cron: daily at 3am UTC"
echo "    Local retention: 30 days"
echo "    S3: s3://backups-kleer/eventer/ (365 days)"
REMOTE

echo ""
echo "Done! Verify with:"
echo "  ssh appuser@$SERVER_IP 'crontab -l'"
echo "  ssh appuser@$SERVER_IP '~/.local/bin/aws s3 ls s3://backups-kleer/eventer/'"
