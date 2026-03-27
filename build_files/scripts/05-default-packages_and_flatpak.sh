#!/bin/bash

set -ouex pipefail

dnf5 -y remove firefox firefox-langpacks toolbox plasma-discover-rpm-ostree plasma-welcome-fedora
rm -rf /etc/skel/.mozilla   # remove excess mozilla config

# Replace fedora logos with generic logos
dnf5 -y swap fedora-logos generic-logos

# Category: Hardware & Peripheral Management
dnf5 -y install libratbag-ratbagd solaar-udev openrgb-udev-rules nvme-cli smartmontools lshw powerstat intel-vaapi-driver alsa-firmware

# Category: Containers & Sandboxing
dnf5 -y install distrobox flatpak-spawn kind

# Category: Terminal Utilities & Productivity
dnf5 -y install fastfetch nano htop tmux fzf just wl-clipboard

# Category: Networking & Connectivity
dnf5 -y install net-tools tcpdump traceroute wireguard-tools

# Category: Security & Authentication
dnf5 -y install yubikey-manager pam-u2f pam_yubico pamu2fcfg

# Category: Mobile Device Support
dnf5 -y install libimobiledevice-utils usbmuxd

# Category: Typography & Internationalization
dnf5 -y install google-noto-sans-balinese-fonts google-noto-sans-cjk-fonts google-noto-sans-javanese-fonts google-noto-sans-sundanese-fonts

# Category: Graphics, Media & Thumbnails
dnf5 -y install heif-pixbuf-loader libheif ffmpegthumbnailer fdk-aac libfdk-aac ffmpeg ffmpeg-libs libavcodec

# Category: Multimedia Infrastructure & Cameras
dnf5 -y install libcamera libcamera-gstreamer libcamera-ipa libcamera-tools pipewire-libs-extra pipewire-plugin-libcamera

# Category: Filesystem & Archive Tools
dnf5 -y install zstd fuse squashfs-tools symlinks

# Category: System Libraries & Low-Level Tools
dnf5 -y install nvtop apr apr-util openssl grub2-tools-extra

# Category: Virtualization
dnf5 -y install libvirt libvirt-daemon-config-network qemu-kvm virt-manager virt-viewer

# Umu launcher, enables proton without requiring Steam
dnf5 -y install nobara-gpg-keys --nogpgcheck \
    --repofrompath="nobara-temp,https://mirrors.nobaraproject.org/rolling/baseos" \
    --setopt="nobara-temp.mirrorlist=https://mirrors.nobaraproject.org/rolling/baseos" \
    --enablerepo="nobara-temp" \
    --best
dnf5 -y install umu-launcher \
    --repofrompath="nobara-temp,https://mirrors.nobaraproject.org/rolling/baseos" \
    --setopt="nobara-temp.mirrorlist=https://mirrors.nobaraproject.org/rolling/baseos" \
    --enablerepo="nobara-temp" \
    --setopt="nobara-temp.gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-nobara-baseos-pubkey-43" \
    --best
dnf5 -y remove nobara-gpg-keys

# umu_launcher_ver=1.4.0 
# dnf5 -y install "https://github.com/Open-Wine-Components/umu-launcher/releases/download/${umu_launcher_ver}/umu-launcher-${umu_launcher_ver}.fc43.x86_64.rpm"

# Add Flathub to the image for eventual application
mkdir -p /etc/flatpak/remotes.d/

# Add flathub repo
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo