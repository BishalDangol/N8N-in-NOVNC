#!/bin/bash
set -e

export USER=root
export HOME=/root

echo "Starting VNC..."
vncserver :1 -geometry 1360x768

echo "Starting n8n..."
n8n start &

echo "Starting noVNC..."
cd /noVNC-1.2.0
./utils/launch.sh --vnc localhost:5901 --listen 8900
