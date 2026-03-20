<div align="center">
    <img src="build_files\files\usr\share\icons\hicolor\scalable\callisto-logo.svg" width=96>
    <h1>Callisto</h1>
</div>

## Features

- Base Image: quay.io/fedora-ostree-desktops/kinoite:43
- desktop environment: KDE Plasma
- Darkly theme as default for KDE Plasma: https://github.com/Bali10050/Darkly/
- kernel-cachyos-lto: https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-lto/
- cachy-os settings and ksm settings: https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-addons/
- Ublue akmods (hardware support): https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/
- Non-free multimedia packages
- A small list of default packages
- ~~Flathub repo replacing the default fedora flatpak repo~~ Currently disabled because buggy
- Ublue-os non-free firmware: https://github.com/ublue-os/bazzite-firmware-nonfree
- Zsh default terminal with autosuggestion, syntax highlighting, and history substring.

## Screenshot

<div align="center">
    <img src="screenshots/Callisto.png" width=700>
</div>

## Installation instructions

Install any atomic Fedora distribution (Kinoite is recommended) and then run: 
```
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/qkmaxware/callisto
```

**OR** 

[Build an ISO](#build-your-own-iso) as described below, flash it to a USB device and install it as per the normal linux install process. 

## Build your own ISO

Ensure podman is installed and run the following command:

```
sudo podman run --rm --privileged --volume .:/build-container-installer/build ghcr.io/jasonn3/build-container-installer:latest -e IMAGE_REPO=ghcr.io/qkmaxware -e IMAGE_NAME=callisto -e IMAGE_TAG=latest -e VERSION=43 -e VARIANT=Kinoite -e EXTRA_BOOT_PARAMS="inst.lang=en_CA.UTF-8 -e ISO_NAME=build/callisto.iso"
```
