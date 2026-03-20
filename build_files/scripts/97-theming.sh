#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable deltacopy/darkly
dnf5 -y install darkly
dnf5 -y copr disable deltacopy/darkly

mkdir -p /usr/share/plasma/look-and-feel/Callisto
cp -rf /ctx/files/usr/share/plasma/look-and-feel/Callisto /usr/share/plasma/look-and-feel/

kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage Callisto