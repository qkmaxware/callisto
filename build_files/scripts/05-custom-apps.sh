#!/bin/bash

set -ouex pipefail

mkdir -p /usr/share/applications

## WebappManager
mkdir -p /usr/lib/WebappManager

cp -r ctx/files/usr/lib/WebappManager/* /usr/lib/WebappManager
cp -r ctx/files/usr/share/applications/WebappManager.desktop /usr/share/applications

# Create a symlink so 'webapp-manager' works in the terminal
ln -s /usr/lib/WebappManager/WebappManager.py /usr/bin/webapp-manager
chmod +x /usr/lib/WebappManager/WebappManager.py

# Install rqd python-pyside6
dnf5 -y install python-pyside6