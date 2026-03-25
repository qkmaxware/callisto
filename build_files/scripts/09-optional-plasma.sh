#!/bin/bash

set -ouex pipefail

# Add the fluid tile autotiling kwin script
fluid_tile_ver=7.2
curl -L -o "/usr/share/kwin/scripts/fluid-tile-v${fluid_tile_ver}.kwinscript" "https://codeberg.org/Serroda/fluid-tile/releases/download/v${fluid_tile_ver}/fluid-tile-v${fluid_tile_ver}.kwinscript"
kpackagetool6 --global --type=KWin/Script -i /usr/share/kwin/scripts/fluid-tile-v7.2.kwinscript