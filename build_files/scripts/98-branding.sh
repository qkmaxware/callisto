#!/usr/bin/env bash

set -ouex pipefail

# Change Fedora logo to Callisto Logo
mkdir -p /usr/share/icons/hicolor/scalable/apps
cp -f ctx/files/usr/share/icons/hicolor/scalable/callisto-logo.svg /usr/share/icons/hicolor/scalable/apps/distribution-logo.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/callisto-logo.svg /usr/share/icons/hicolor/scalable/apps/callisto-logo.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/callisto-logo.svg /usr/share/icons/hicolor/scalable/apps/fedora-logo-icon.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/callisto-logo.svg /usr/share/icons/hicolor/scalable/apps/fedora-logo-sprite.svg

mkdir -p /usr/share/pixmaps
cp -f ctx/files/usr/share/pixmaps/callisto-logo.png /usr/share/pixmaps/fedora-logo.png
cp -f ctx/files/usr/share/pixmaps/callisto-logo.svg /usr/share/pixmaps/system-logo-white.png
cp -f ctx/files/usr/share/pixmaps/callisto-logo.svg /usr/share/pixmaps/fedora-logo-small.png

# Change "start-here" application launcher icon to a modified logo
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-dark.svg /usr/share/icons/breeze-dark/places/16/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-dark.svg /usr/share/icons/breeze-dark/places/22/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-dark.svg /usr/share/icons/breeze-dark/places/24/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-dark.svg /usr/share/icons/breeze-dark/places/32/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-dark.svg /usr/share/icons/breeze-dark/places/64/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-dark.svg /usr/share/icons/breeze-dark/places/96/start-here-kde-symbolic.svg

cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-light.svg /usr/share/icons/breeze/places/16/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-light.svg /usr/share/icons/breeze/places/22/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-light.svg /usr/share/icons/breeze/places/24/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-light.svg /usr/share/icons/breeze/places/32/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-light.svg /usr/share/icons/breeze/places/64/start-here-kde-symbolic.svg
cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here-light.svg /usr/share/icons/breeze/places/96/start-here-kde-symbolic.svg