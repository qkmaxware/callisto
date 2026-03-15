#!/usr/bin/bash

set -eoux pipefail

# Enable Update Timers
systemctl enable rpm-ostreed-automatic.timer

# Configure staged updates for rpm-ostree
cp /usr/share/ublue-os/update-services/etc/rpm-ostreed.conf /etc/rpm-ostreed.conf

# Package manager cleanup
dnf5 clean all 2>/dev/null || true
find /var/cache/dnf /var/cache/dnf5 /var/lib/dnf -mindepth 1 -delete 2>/dev/null || true
find /var/log/dnf5.log -delete 2>/dev/null || true

# System temp directories cleanup
find /tmp /var/tmp /run -mindepth 1 -maxdepth 1 -delete 2>/dev/null || true

# Boot directory cleanup
find /boot -mindepth 1 -maxdepth 1 -delete 2>/dev/null || true

# Ruby gem cache cleanup
find /root/.gem -delete 2>/dev/null || true
find /tmp -name "gem*" -delete 2>/dev/null || true

# Installer and stray root files cleanup
find / -maxdepth 1 \( -name "nvim.root" -o -name "dnf" -o -name "selinux-policy" \) -delete 2>/dev/null || true

# Specific hidden file cleanup
find . -maxdepth 1 \( -name ".wget-hsts*" -o -name ".wget-hpkp*" -o -name ".wh.*" -o -name ".*_lck_*" \) -delete 2>/dev/null || true

# Generate bootloader metadata for the installer
if command -v bootupctl &> /dev/null; then
    bootupctl backend generate-update-metadata
fi