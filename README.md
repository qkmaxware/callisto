<div align="center">
    <img src="build_files\files\usr\share\icons\hicolor\scalable\callisto-logo.svg" width=96>
    <h1>Callisto</h1>
</div>

Callisto is a galaxy themed Fedora-based image, designed to be frictionless and enjoyable for most people running modern Intel/AMD systems. Why would you install Callisto?

- You really enjoy astrophotography.
- You want an OS that *looks* and *feels* great out of the box.
- Built as an atomic distribution, this makes it very difficult to break your system.
- Improved kernel scheduling for a more responsive system.
- Better ram management than stock Fedora.
- Increased hardware support over stock Fedora.
- Includes a small list of QOL improvements.

Callisto runs a custom theme composing of multiple different community projects. Callisto aims to feel a lot like how Windows *should* feel without any of the poor design choices.

## Screenshot

<div align="center">
    <img src="screenshots/Callisto.png" width=700>
</div>


## Specifications

| Component | Feature | Description | Notes |
|-----------|---------|-------------|-------|
| OS        |         |             |       |
|           | Base Image | quay.io/fedora-ostree-desktops/kinoite:43 | |
| Desktop   |         |             |       |
|           | Environment | KDE Plasma |    |
|           | Theme   | [Darkly Theme](https://github.com/Bali10050/Darkly/) | Makes Plasma look a lot more modern. |
|           | Icons   | [Tela Icon Theme](https://github.com/vinceliuice/Tela-icon-theme) | Flat design icons which look great paired with the Darkly theme. |
|           | App Launcher | [AppGrid Application Launcher](https://github.com/xarbit/plasma6-applet-appgrid) | Cosmic-style app launcher optimized for search and every-day app launching. |
| Kernel    |         |             |       |
|           | Base    | [CachyOS LTO](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-lto/) | |
|           | Settings | [CachyOS and KSM](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-addons/) | |
|           | Hardware Support | [Ublue akmods](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/) | |
|           | Firmware | [Ublue-os non-free firmware](https://github.com/ublue-os/bazzite-firmware-nonfree) | |
| Packages  |         |             |       |
|           | Multimedia | Non-free multimedia packages | |
|           | Default Apps | A small number common default apps | |
|           | Custom Apps | Custom applications like [WebappManager](./build_files/files/usr/lib/WebappManager/) | |
| Repositories ||||
|           | Flathub | [Flathub Repository](https://flathub.org/en) | |
|           | Fedora Flatpak | Fedora default flatpak repository | |
| Terminal  ||||
|           | Shell | [Zsh](https://www.zsh.org/) | |

## Installation instructions

Install any atomic Fedora distribution (Kinoite is recommended) and then run: 
```sh
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/qkmaxware/callisto
```

**OR** 

[Build an ISO](#build-your-own-iso) as described below, flash it to a USB device and install it as per the normal linux install process. 

## Build your own ISO

Ensure podman is installed and run the following command:

```
sudo podman run --rm --privileged --volume .:/build-container-installer/build ghcr.io/jasonn3/build-container-installer:latest -e IMAGE_REPO=ghcr.io/qkmaxware -e IMAGE_NAME=callisto -e IMAGE_TAG=latest -e VERSION=43 -e VARIANT=Kinoite -e EXTRA_BOOT_PARAMS=inst.lang=en_CA.UTF-8 -e ISO_NAME=build/callisto.iso
```

If using Docker instead of Podman simply replace `podman` in the above command with `docker`. This also works in windows without sudo.
