#!/bin/bash

set -ouex pipefail

mkdir -p /usr/share/applications

# Install rqd python-pyside6 (dependency for webapp-manager)
dnf5 -y install python-pyside6

## WebappManager
dnf5 -y install webapp-manager --repo callisto

## ResetHome
mkdir -p /usr/lib/ResetHome
cp -r ctx/files/usr/lib/ResetHome/* /usr/lib/ResetHome

ln -s /usr/lib/ResetHome/ResetHome.py /usr/bin/reset-home
chmod +x /usr/lib/ResetHome/ResetHome.py