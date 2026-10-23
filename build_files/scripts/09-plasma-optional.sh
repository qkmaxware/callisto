#!/bin/bash

set -ouex pipefail

### Karousel
# 1. Packages required for karousel
dnf5 install -y kf6-knotifications qt6-qtdeclarative

# 2. Fetch the latest release tag from GitHub API (e.g., "v0.17")
latest_tag=$(curl -s https://api.github.com/repos/peterfajdiga/karousel/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)

# Strip the 'v' prefix for the local filename
karousel_ver=${latest_tag#v}

# 3. Download and install the latest Karousel release
curl -L -o "/usr/share/kwin/scripts/karousel-v${karousel_ver}.tar.gz" "https://github.com/peterfajdiga/karousel/releases/download/${latest_tag}/karousel.tar.gz"
kpackagetool6 --global --type=KWin/Script -i "/usr/share/kwin/scripts/karousel-v${karousel_ver}.tar.gz"