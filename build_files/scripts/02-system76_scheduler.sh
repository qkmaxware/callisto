#!/bin/bash

set -ouex pipefail

# Install the System76 userspace scheduler
dnf5 -y install system76-scheduler \
  --repofrompath='system76-scheduler,https://download.copr.fedorainfracloud.org/results/kylegospo/system76-scheduler/fedora-$releasever-x86_64/' \
  --setopt="system76-scheduler.gpgkey=https://download.copr.fedorainfracloud.org/results/kylegospo/system76-scheduler/pubkey.gpg"

# Install the KDE integration for System76 userspace scheduler
mkdir /tmp/kwinscripts
git clone --depth 1 https://github.com/maxiberta/kwin-system76-scheduler-integration.git /tmp/kwinscripts/kwin-system76-scheduler-integration
kpackagetool6 --global --type=KWin/Script -i /tmp/kwinscripts/kwin-system76-scheduler-integration
rm -rf /tmp/kwinscripts

# Add the documented workaround required for KDE integration
cp -f /ctx/files/usr/bin/system76-scheduler-dbus-proxy.sh /usr/bin/
chmod +x /usr/bin/system76-scheduler-dbus-proxy.sh

# Add system service
tee "/usr/lib/systemd/system/com.system76.Scheduler.dbusproxy.service" > /dev/null <<EOF
[Unit]
Description=Forward com.system76.Scheduler session DBus messages to the system bus

[Service]
ExecStart=/usr/bin/system76-scheduler-dbus-proxy.sh

[Install]
WantedBy=default.target
EOF

# Enable the system service
ln -s /usr/lib/systemd/system/com.system76.Scheduler.dbusproxy.service /etc/systemd/system/multi-user.target.wants/com.system76.Scheduler.dbusproxy.service



