#!/bin/bash

echo "Stopping Docker services..."
systemctl stop docker 2>/dev/null
systemctl stop docker.socket 2>/dev/null

echo "Purging Docker packages..."
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Removing snap Docker (if installed)..."
snap list | grep docker && snap remove docker

echo "Cleaning up unused packages..."
apt-get autoremove -y --purge
apt-get autoclean

echo "Removing Docker directories and data..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker
rm -rf /run/docker
rm -rf /var/run/docker.sock
rm -rf /var/lib/docker-network

echo "Disabling and masking systemd services..."
systemctl disable docker 2>/dev/null
systemctl mask docker 2>/dev/null
systemctl disable containerd 2>/dev/null
systemctl mask containerd 2>/dev/null

echo "Removing systemd service unit files..."
rm -f /usr/lib/systemd/system/docker.service
rm -f /usr/lib/systemd/system/docker.socket
rm -f /etc/systemd/system/docker.service
rm -f /etc/systemd/system/docker.socket

echo "Reloading systemd daemon..."
systemctl daemon-reexec
systemctl daemon-reload

echo "Removing leftover Docker binaries..."
rm -f /usr/bin/docker*
rm -f /usr/local/bin/docker*

echo "Removing Docker group if it exists..."
getent group docker && groupdel docker

echo "Verifying Docker removal..."
if ! systemctl status docker &>/dev/null; then
    echo "Docker systemd service successfully removed."
else
    echo "⚠️ Docker systemd service still present!"
fi

which docker || echo "✅ Docker binary not found"
ps aux | grep -i docker | grep -v grep || echo "✅ No Docker processes running"

echo "✅ Docker has been completely removed from your system."
