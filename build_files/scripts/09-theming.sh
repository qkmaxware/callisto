#!/bin/bash

set -ouex pipefail

releasever=$(rpm -E '%fedora')

# TODO replace all the below with this single one-liner
#dnf5 -y install callisto-theme --repo callisto

# Install the darkly theme
dnf5 -y install darkly \
  --repofrompath='darkly,https://download.copr.fedorainfracloud.org/results/deltacopy/darkly/fedora-$releasever-x86_64/' \
  --setopt="darkly.gpgkey=https://download.copr.fedorainfracloud.org/results/deltacopy/darkly/pubkey.gpg"

# Install tela icon theme
git clone --depth 1 https://github.com/vinceliuice/Tela-icon-theme.git
./Tela-icon-theme/install.sh -c -d /usr/share/icons -n "Tela (Callisto)"
rm -rf Tela-icon-theme

# Overwrite tela's start-here logo with callisto
for dir in '/usr/share/icons/Tela (Callisto)/32/status/' '/usr/share/icons/Tela (Callisto)/24/panel/' '/usr/share/icons/Tela (Callisto)/22/panel/' '/usr/share/icons/Tela (Callisto)/16/panel/'; do sudo cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here.svg "$dir"; done

# Install Darkly Callisto color theme
mkdir -p /usr/share/color-schemes
cp -f ctx/files/usr/share/color-schemes/DarklyCallisto.colors /usr/share/color-schemes

# Add the Callisto SDDM theme
dnf5 -y install callisto-theme-sddm --repo callisto

# Add the Callisto theme
mkdir -p /usr/share/plasma/look-and-feel/Callisto
cp -rf /ctx/files/usr/share/plasma/look-and-feel/Callisto /usr/share/plasma/look-and-feel/

kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage Callisto

# Rip out default installed wallpapers (minus a few special ones)
# Download my astro-images as wallpapers
dnf5 -y remove plasma-workspace-wallpapers
dnf5 -y install callisto-backgrounds --repo callisto