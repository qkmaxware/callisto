#!/bin/bash

set -ouex pipefail

mkdir -p /usr/share/plasma/plasma-welcome/
cp -rf /ctx/files/usr/share/plasma/plasma-welcome/. /usr/share/plasma/plasma-welcome/

chmod +x /usr/share/plasma/plasma-welcome/extra-pages/workflows/*.sh
chmod +x /usr/share/plasma/plasma-welcome/extra-pages/workflows/*.desktop