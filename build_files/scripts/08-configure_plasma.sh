#!/bin/bash

set -ouex pipefail

kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key AnimationDurationFactor 0.35

# Download geometry change kwin effect, configure it, and enable it by default 
geometry_change_ver=1.5
curl -L "https://github.com/peterfajdiga/kwin4_effect_geometry_change/releases/download/v${geometry_change_ver}/kwin4_effect_geometry_change_${geometry_change_ver//./_}.tar.gz" \
| tar -xzC "/usr/share/kwin/effects/" --strip-components=1
kwriteconfig6 --file /etc/xdg/kwinrc --group Effect-kwin4_effect_geometry_change --key Duration 500
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key "kwin4_effect_geometry_changeEnabled" true