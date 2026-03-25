#!/bin/bash

set -ouex pipefail

# Install the System76 userspace scheduler
dnf5 -y install system76-scheduler \
  --repofrompath='system76-scheduler,https://download.copr.fedorainfracloud.org/results/kylegospo/system76-scheduler/fedora-$releasever-x86_64/' \
  --setopt="system76-scheduler.gpgkey=https://download.copr.fedorainfracloud.org/results/kylegospo/system76-scheduler/pubkey.gpg"

mkdir /tmp/kwinscripts

git clone --depth 1 https://github.com/maxiberta/kwin-system76-scheduler-integration.git /tmp/kwinscripts/kwin-system76-scheduler-integration
kpackagetool6 --global --type=KWin/Script -i /tmp/kwinscripts/kwin-system76-scheduler-integration

rm -rf /tmp/kwinscripts