#!/bin/bash

# Update to newest release of cosmic
dnf5 -y copr enable ryanabx/cosmic-epoch
dnf5 -y install cosmic-desktop --allowerasing