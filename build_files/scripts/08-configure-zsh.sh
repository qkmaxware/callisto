#!/bin/bash

set -ouex pipefail

dnf5 -y install \
    zsh util-linux-user

curl -sS https://starship.rs/install.sh | sh -s -- --yes -b /usr/bin

# 1. Create the system-wide Zsh configuration
# This ensures every new user gets the Ultramarine style
mkdir -p /etc/skel/.zsh

# 2. Download Ultramarine/Standard Zsh plugins into the system skeleton
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /etc/skel/.zsh/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting /etc/skel/.zsh/zsh-syntax-highlighting
git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search /etc/skel/.zsh/zsh-history-substring-search

rm -rf /etc/skel/.zsh/zsh-autosuggestions/.git
rm -rf /etc/skel/.zsh/zsh-syntax-highlighting/.git
rm -rf /etc/skel/.zsh/zsh-history-substring-search/.git

# 3. Create the default .zshrc in /etc/skel
cp /ctx/files/etc/skel/.zshrc /etc/fastfetch/.zshrc

# 4. Set the default Starship preset
mkdir -p /etc/skel/.config
starship preset bracketed-segments -o /etc/skel/.config/starship.toml

# 5. Set Zsh as the default shell for the image
# On uBlue/Atomic, we modify /etc/default/useradd or just set it via usermod for existing users
cp /etc/default/useradd /etc/default/useradd.tmp
sed 's/SHELL=\/bin\/bash/SHELL=\/usr\/bin\/zsh/g' /etc/default/useradd.tmp > /etc/default/useradd
rm /etc/default/useradd.tmp

