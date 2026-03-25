#!/bin/bash

set -ouex pipefail

kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key AnimationDurationFactor 0.35

mkdir /tmp/effects

# Download geometry change kwin effect, configure it, and enable it by default 
geometry_change_ver=1.5
curl -L "https://github.com/peterfajdiga/kwin4_effect_geometry_change/releases/download/v${geometry_change_ver}/kwin4_effect_geometry_change_${geometry_change_ver//./_}.tar.gz" \
| tar -xzC "/tmp/effects/" --strip-components=1
kwriteconfig6 --file /etc/xdg/kwinrc --group Effect-kwin4_effect_geometry_change --key Duration 500
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key "kwin4_effect_geometry_changeEnabled" true
kpackagetool6 --global --type=KWin/Effect -i /tmp/effects/kwin4_effect_geometry_change

# Install the Squash-Plus kwin effect, configure it, and enable it by default
git clone --depth 1 https://github.com/Shaurya-Kalia/Squash-Plus.git /tmp/effects/Squash-Plus

kwriteconfig6 --file /etc/xdg/kwinrc --group "Effect-kwin4_effect_squashplus" --group "General" --key Duration 1000
kwriteconfig6 --file /etc/xdg/kwinrc --group "Effect-kwin4_effect_squashplus" --group "General" --key Opacity 80
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key "kwin4_effect_squashplusEnabled" true

kpackagetool6 --global --type=KWin/Effect -i /tmp/effects/Squash-Plus

rm -rf /tmp/effects