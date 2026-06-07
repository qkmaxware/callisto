#!/bin/bash

set -ouex pipefail

mkdir -p /usr/share/applications

# Install rqd python-pyside6 (dependency for webapp-manager)
dnf5 -y install python-pyside6

## WebappManager
dnf5 -y install webapp-manager --repo callisto

## ResetHome
dnf5 -y install reset-home --repo callisto