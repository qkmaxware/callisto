#!/usr/bin/env bash

set -ouex pipefail

dnf5 -y copr enable deltacopy/darkly
dnf5 -y install darkly
dnf5 -y copr disable deltacopy/darkly