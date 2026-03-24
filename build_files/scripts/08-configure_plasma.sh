#!/bin/bash

set -ouex pipefail

kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key AnimationDurationFactor 0.35