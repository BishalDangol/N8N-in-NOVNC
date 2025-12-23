FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Enable i386 (needed for wine)
RUN dpkg --add-architecture i386

# Install system packages
RUN apt update && apt install -y \
    wget curl git dbus-x11 xz-utils \
    xfce4 xfce4-terminal \
    tightvncserver \
    firefox-esr \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Install n8n
RUN npm install -g n8n

# Install noVNC
WORKDIR /
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz \
 && tar -xzf v1.2.0.tar.gz \
 && rm v1.2.0.tar.gz

# VNC setup
RUN mkdir -p /root/.vnc \
 && echo 'admin123@a' | vncpasswd -f > /root/.vnc/passwd \
 && chmod 600 /root/.vnc/passwd \
 && echo '#!/bin/sh\nexec dbus-launch xfce4-session &' > /root/.vnc/xstartup \
 && chmod +x /root/.vnc/xstartup

# Startup script
RUN cat <<'EOF' > /start.sh
#!/bin/bash
set -e

# Start VNC
vncserver :1 -geometry 1360x768

# Start n8n
n8n start &

# Start noVNC
cd /noVNC-1.2.0
./utils/launch.sh --vnc localhost:5901 --listen 8900
EOF

RUN chmod +x /start.sh

# Expose ports
EXPOSE 8900 5678

CMD ["/start.sh"]
