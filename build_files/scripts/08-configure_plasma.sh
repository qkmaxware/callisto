#!/bin/bash

set -ouex pipefail

# Make plasma feel more snappy
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key AnimationDurationFactor 0.35

appgrid_ver=1.7.5
# Install the appgrid widget
dnf5 -y install "https://github.com/xarbit/plasma6-applet-appgrid/releases/download/v${appgrid_ver}/plasma-applet-appgrid-${appgrid_ver}-1.fc43.x86_64.rpm"
# Change the defaults with a patch
patch /usr/share/plasma/plasmoids/dev.xarbit.appgrid/contents/config/main.xml -i /ctx/files/usr/share/plasma/plasmoids/dev.xarbit.appgrid/contents/config/main.xml.patch

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