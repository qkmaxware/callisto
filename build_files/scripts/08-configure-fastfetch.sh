#!/bin/bash

set -ouex pipefail

# Load in fastfetch configs
mkdir -p /etc/fastfetch
cp -r /ctx/files/etc/fastfetch/* /etc/fastfetch
