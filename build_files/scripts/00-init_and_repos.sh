#!/bin/bash

set -ouex pipefail

if [[ "$(rpm -E %fedora)" -gt 41 ]]; then
  dnf5 -y copr enable ublue-os/staging
  dnf5 -y swap --repo='copr:copr.fedorainfracloud.org:ublue-os:staging' \
    rpm-ostree rpm-ostree
  dnf5 versionlock add rpm-ostree
  dnf5 -y copr disable ublue-os/staging
fi

## DNF5 Speedup
cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.tmp
sed '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf.tmp > /etc/dnf/dnf.conf
rm /etc/dnf/dnf.conf.tmp

# Install the RPMFusion repos
dnf5 -y install --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 -y install --nogpgcheck https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm