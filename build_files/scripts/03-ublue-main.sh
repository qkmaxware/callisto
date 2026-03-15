#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable ublue-os/packages
dnf5 -y install ublue-os-udev-rules ublue-os-update-services
dnf5 versionlock add ublue-os-udev-rules ublue-os-update-services
dnf5 -y copr disable ublue-os/packages