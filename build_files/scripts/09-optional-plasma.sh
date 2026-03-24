#!/bin/bash

set -ouex pipefail

# Install the appgrid widget
dnf5 -y install https://github.com/xarbit/plasma6-applet-appgrid/releases/download/v1.7.4/plasma-applet-appgrid-1.7.4-1.fc43.x86_64.rpm

# Add the fluid tile autotiling kwin script
fluid_tile_ver=7.2
curl -L -o "/usr/share/kwin/scripts/fluid-tile-v${fluid_tile_ver}.kwinscript" "https://codeberg.org/Serroda/fluid-tile/releases/download/v${fluid_tile_ver}/fluid-tile-v${fluid_tile_ver}.kwinscript"
kpackagetool6 --type=KWin/Script -i "/usr/share/kwin/scripts/fluid-tile-v${fluid_tile_ver}.kwinscript"