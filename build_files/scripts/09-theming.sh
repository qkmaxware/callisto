#!/bin/bash

set -ouex pipefail

releasever=$(rpm -E '%fedora')

# Install the darkly theme
dnf5 -y install darkly \
  --repofrompath='darkly,https://download.copr.fedorainfracloud.org/results/deltacopy/darkly/fedora-$releasever-x86_64/' \
  --setopt="darkly.gpgkey=https://download.copr.fedorainfracloud.org/results/deltacopy/darkly/pubkey.gpg"

# Install tela icon theme
dnf5 -y install callisto-tela-icon-theme --repo callisto

# Add the Callisto theme
dnf5 -y install callisto-theme --repo callisto
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage Callisto

# Rip out default installed wallpapers (minus a few special ones)
# Download my astro-images as wallpapers
dnf5 -y remove plasma-workspace-wallpapers
dnf5 -y install callisto-backgrounds --repo callisto