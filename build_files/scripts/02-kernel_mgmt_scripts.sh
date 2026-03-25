#!/bin/bash

set -ouex pipefail

# Install CachyOS kernel addons
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
# Required to install CachyOS settings
rm -rf /usr/lib/systemd/coredump.conf
# Install KSMD and CachyOS-Settings
dnf5 -y install cachyos-settings cachyos-ksm-settings --allowerasing

dnf5 versionlock add cachyos-settings cachyos-ksm-settings
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

# Add KSMD service
tee "/usr/lib/systemd/system/ksmd.service" > /dev/null <<EOF
[Unit]
Description=Activates Kernel Samepage Merging
ConditionPathExists=/sys/kernel/mm/ksm

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/ksmctl -e
ExecStop=/usr/bin/ksmctl -d

[Install]
WantedBy=multi-user.target
EOF

# Enable the KSMD service
ln -s /usr/lib/systemd/system/ksmd.service /etc/systemd/system/multi-user.target.wants/ksmd.service

# Install the System76 userspace scheduler
dnf5 -y install system76-scheduler \
  --repofrompath='system76-scheduler,https://download.copr.fedorainfracloud.org/results/kylegospo/system76-scheduler/fedora-$releasever-x86_64/' \
  --setopt="system76-scheduler.gpgkey=https://download.copr.fedorainfracloud.org/results/kylegospo/system76-scheduler/pubkey.gpg"

# Enable the System76 userspace scheduler
ln -s /usr/lib/systemd/system/com.system76.Scheduler.service /etc/systemd/system/multi-user.target.wants/com.system76.Scheduler.service

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
