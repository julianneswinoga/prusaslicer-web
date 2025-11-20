FROM prusaslicer_base

ARG VIRTUALGL_VERSION=3.1.4
ARG TURBOVNC_VERSION=3.2.1

ENV DEBIAN_FRONTEND=noninteractive
RUN bash <<'EOF'
set -eu


base_deps=(locales xterm novnc lxqt-core openbox gosu supervisor)
turbovnc_deps=(dbus-x11 xauth x11-xkb-utils libxfont2)

apt-get update
apt-get install -y --no-install-recommends "${base_deps[@]}" "${turbovnc_deps[@]}"

mkdir -p /usr/share/desktop-directories

apt-get autoclean -y
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
EOF

# Install VirtualGL and TurboVNC
RUN bash <<'EOF'
set -eu

wget -qO /tmp/virtualgl_${VIRTUALGL_VERSION}_amd64.deb https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb
dpkg -i /tmp/virtualgl_${VIRTUALGL_VERSION}_amd64.deb

wget -qO /tmp/turbovnc_${TURBOVNC_VERSION}_amd64.deb https://github.com/TurboVNC/turbovnc/releases/download/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb
dpkg -i /tmp/turbovnc_${TURBOVNC_VERSION}_amd64.deb
rm -rf /tmp/*.deb
EOF

# User setup
RUN bash <<'EOF'
set -eu

adduser --disabled-password --quiet --comment '' slic3r
mkdir /prints/
mkdir -p /configs/.local/
mkdir -p /configs/.config/
ln -s /configs/.config/ /home/slic3r/

mkdir -p /home/slic3r/.config/gtk-3.0/
echo "file:///prints
file:///configs" > /home/slic3r/.config/gtk-3.0/bookmarks

chown -R slic3r:slic3r /home/slic3r/ /prints/ /configs/

locale-gen en_US
EOF

# Generate key for noVNC
RUN bash <<'EOF'
set -eu

openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/novnc.pem -out /etc/novnc.pem -days 365 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost"
EOF

ENV PATH=${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin

ADD entrypoint.sh /entrypoint.sh
ADD supervisord.conf /etc/

# Create log directory for supervisord
RUN bash <<'EOF'
set -eu

mkdir -p /var/log/supervisord
touch /var/log/supervisord.log
chown slic3r:slic3r /var/log/supervisord /var/log/supervisord.log
EOF

# Add a default file to resize and redirect, and adjust icons for noVNC.
ADD vncresize.html /usr/share/novnc/index.html
ADD icons/prusaslicer-16x16.png /usr/share/novnc/app/images/icons/novnc-16x16.png
ADD icons/prusaslicer-24x24.png /usr/share/novnc/app/images/icons/novnc-24x24.png
ADD icons/prusaslicer-32x32.png /usr/share/novnc/app/images/icons/novnc-32x32.png
ADD icons/prusaslicer-48x48.png /usr/share/novnc/app/images/icons/novnc-48x48.png
ADD icons/prusaslicer-60x60.png /usr/share/novnc/app/images/icons/novnc-60x60.png
ADD icons/prusaslicer-64x64.png /usr/share/novnc/app/images/icons/novnc-64x64.png
ADD icons/prusaslicer-72x72.png /usr/share/novnc/app/images/icons/novnc-72x72.png
ADD icons/prusaslicer-76x76.png /usr/share/novnc/app/images/icons/novnc-76x76.png
ADD icons/prusaslicer-96x96.png /usr/share/novnc/app/images/icons/novnc-96x96.png
ADD icons/prusaslicer-120x120.png /usr/share/novnc/app/images/icons/novnc-120x120.png
ADD icons/prusaslicer-144x144.png /usr/share/novnc/app/images/icons/novnc-144x144.png
ADD icons/prusaslicer-152x152.png /usr/share/novnc/app/images/icons/novnc-152x152.png
ADD icons/prusaslicer-192x192.png /usr/share/novnc/app/images/icons/novnc-192x192.png

VOLUME /configs/
VOLUME /prints/

ENTRYPOINT ["/entrypoint.sh"]
