<div align="center">
    <img src="logo.svg" width=96>
    <h1>Callisto</h1>
</div>

## Features:

- Base Image: quay.io/fedora-ostree-desktops/kinoite:43
- kernel-cachyos-lto: https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-lto/
- cachy-os settings and ksm settings: https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-addons/
- Ublue akmods (hardware support): https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/
- Non-free multimedia packages
- A small list of default packages
- Flathub repo replacing the default fedora flatpak repo
- Ublue-os non-free firmware: https://github.com/ublue-os/bazzite-firmware-nonfree
- Zsh default terminal with autosuggestion, syntax highlighting, and history substring.

## Installation instructions:

Install any atomic Fedora distribution (Silverblue, Kinoite, Bazzite, Aurora, ...)

Run:

`rpm-ostree rebase ostree-image-signed:docker://ghcr.io/qkmaxware/callisto`
