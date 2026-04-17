#!/bin/bash

set -ouex pipefail

mkdir -p /usr/share/plasma/plasma-welcome/
cp -rf /ctx/files/usr/share/plasma/plasma-welcome/. /usr/share/plasma/plasma-welcome/

cp -rf /ctx/files/usr/lib/Workflows /usr/lib/
chmod +x /usr/lib/Workflows/*.sh

cp /ctx/files/usr/share/applications/github.qkmaxware.callisto.workflow-astro-install.desktop /usr/share/applications/github.qkmaxware.callisto.workflow-astro-install.desktop
chmod +x /usr/share/applications/github.qkmaxware.callisto.workflow-astro-install.desktop
cp /ctx/files/usr/share/applications/github.qkmaxware.callisto.workflow-creative-install.desktop /usr/share/applications/github.qkmaxware.callisto.workflow-creative-install.desktop
chmod +x /usr/share/applications/github.qkmaxware.callisto.workflow-creative-install.desktop

kbuildsycoca