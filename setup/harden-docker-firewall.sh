#!/bin/bash
#
# Harden this ufw-managed Docker host so container ports published on 0.0.0.0
# are NOT reachable from the internet except the ones the host is meant to serve
# (80/443). Run on the server as root. Idempotent.
#   ssh root@SERVER 'bash -s' < setup/harden-docker-firewall.sh
#
# Why: Docker inserts its own iptables rules and bypasses ufw -- ufw only
# filters INPUT, but published container ports enter via DNAT/FORWARD. So a
# container publishing e.g. 5432 on 0.0.0.0 is internet-exposed even with ufw
# "active" and only SSH/80/443 allowed. On 2026-08-14 a bot wiped a Postgres
# reached exactly this way (see fugazzeta docs/incidente-postgres-devcontainer.md).
#
# Fix: the ufw-docker pattern (chaifeng). Published container ports become
# deny-by-default in the FORWARD/routed path; only 80/443 are allowed through.
# This host runs kamal-proxy on 0.0.0.0:80/443 (public entry for every app),
# so 80/443 MUST stay open -- a blanket drop would take all sites down.

set -euo pipefail

echo "==> Allowing 80/443 through the routed (FORWARD) path..."
ufw route allow proto tcp from any to any port 80
ufw route allow proto tcp from any to any port 443

install_block() {
  file="$1"
  if grep -q "BEGIN UFW AND DOCKER" "$file"; then
    echo "==> $file already has ufw-docker block, skipping"
    cat >/dev/null   # consume the heredoc
    return
  fi
  cat >> "$file"
  echo "==> appended ufw-docker block to $file"
}

install_block /etc/ufw/after.rules <<'EOF'

# BEGIN UFW AND DOCKER
*filter
:ufw-user-forward - [0:0]
:ufw-docker-logging-deny - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw-user-forward

-A DOCKER-USER -j RETURN -s 10.0.0.0/8
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j RETURN -s 192.168.0.0/16

-A DOCKER-USER -p udp -m udp --sport 53 --dport 1024:65535 -j RETURN

-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 172.16.0.0/12
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 172.16.0.0/12

-A DOCKER-USER -j RETURN

-A ufw-docker-logging-deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW DOCKER BLOCK] "
-A ufw-docker-logging-deny -j DROP

COMMIT
# END UFW AND DOCKER
EOF

install_block /etc/ufw/after6.rules <<'EOF'

# BEGIN UFW AND DOCKER
*filter
:ufw6-user-forward - [0:0]
:ufw6-docker-logging-deny - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw6-user-forward

-A DOCKER-USER -j RETURN -s fc00::/7
-A DOCKER-USER -j RETURN -s fe80::/10

-A DOCKER-USER -p udp -m udp --sport 53 --dport 1024:65535 -j RETURN

-A DOCKER-USER -j ufw6-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d fc00::/7
-A DOCKER-USER -j ufw6-docker-logging-deny -p udp -m udp --dport 0:32767 -d fc00::/7

-A DOCKER-USER -j RETURN

-A ufw6-docker-logging-deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW DOCKER BLOCK] "
-A ufw6-docker-logging-deny -j DROP

COMMIT
# END UFW AND DOCKER
EOF

echo "==> Reloading ufw..."
ufw reload

echo "==> Done. DOCKER-USER now:"
iptables -S DOCKER-USER
echo ""
echo "Verify a stray published port is blocked (from another machine):"
echo "  docker run --rm -d --name t --entrypoint sleep -p 0.0.0.0:15999:15999 \$(docker images -q | head -1) 120"
echo "  # then externally: 'nc -zv HOST 15999' should TIME OUT; docker rm -f t"
