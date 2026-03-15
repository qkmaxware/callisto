#!/bin/bash

set -ouex pipefail

# Set the default for new users to plasma dark
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key ColorScheme BreezeDark
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop