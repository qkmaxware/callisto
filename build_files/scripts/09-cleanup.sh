#!/usr/bin/bash

set -eoux pipefail

# Enable Update Timers
systemctl enable rpm-ostreed-automatic.timer

# Configure staged updates for rpm-ostree
cp /usr/share/ublue-os/update-services/etc/rpm-ostreed.conf /etc/rpm-ostreed.conf

dnf5 clean all
rm -rf /tmp/* || true
rm -rf /var/log/dnf5.log || true
rm -rf /boot/* || true
rm -rf /boot/.* || true

# Generate bootloader metadata for the installer
if command -v bootupctl &> /dev/null; then
    bootupctl backend generate-update-metadata
fi