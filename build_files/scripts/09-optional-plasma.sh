#!/bin/bash

set -ouex pipefail

# Install the appgrid widget
dnf5 -y install https://github.com/xarbit/plasma6-applet-appgrid/releases/download/v1.7.4/plasma-applet-appgrid-1.7.4-1.fc43.x86_64.rpm

# Add the fluid tile autotiling kwin script
curl -L -o /usr/share/kwin/scripts/fluid-tile-v7.2.kwinscript https://codeberg.org/Serroda/fluid-tile/releases/download/v7.2/fluid-tile-v7.2.kwinscript