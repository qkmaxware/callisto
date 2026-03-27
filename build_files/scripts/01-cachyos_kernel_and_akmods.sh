#!/bin/bash

set -ouex pipefail

#### KERNEL MODIFICATION INIT

# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
cd /usr/lib/kernel/install.d \
&& mv 05-rpmostree.install 05-rpmostree.install.bak \
&& mv 50-dracut.install 50-dracut.install.bak \
&& printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install \
&& printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install \
&& chmod +x  05-rpmostree.install 50-dracut.install

#### CACHY OS KERNEL

# Install CachyOS kernel
dnf5 -y copr enable bieszczaders/kernel-cachyos-lto
dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra 
rm -rf /lib/modules/* # Remove kernel files that remain

dnf5 -y install \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-devel \
    kernel-cachyos-lto-devel-matched --allowerasing
dnf5 versionlock add \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-devel \
    kernel-cachyos-lto-devel-matched
dnf5 -y copr disable bieszczaders/kernel-cachyos-lto

#### UBLUE-OS AKMODS

RELEASE=$(/usr/bin/rpm -E %fedora)
ARCH=$(/usr/bin/rpm -E '%_arch')
KERNEL=$(dnf5 list kernel-cachyos-lto -q | awk '/kernel-cachyos-lto/ {print $2}' | head -n 1 | cut -d'-' -f1)-cachyos1.lto.fc${RELEASE}.${ARCH}

dnf5 -y copr enable ublue-os/akmods

# List of ublue akmods to build
# xone, zenpower3-kmod, and bmi160-kmod fail to compile using LTO kernel
DRIVERS=(
    "openrazer"
    "v4l2loopback"
    "wl"
    "framework-laptop"
    "nct6687"
    "gcadapter_oc"
    "zenergy"
    "vhba"
    "gpd-fan"
    "ayaneo-platform"
    "ayn-platform"
    "bmi260"
    "ryzen-smu"
    "asus-wmi"
    "bmi323"
    "winesync"
    "openrgb"
)

for ITEM in "${DRIVERS[@]}"; do
    echo "Processing: $ITEM..."
    PKG_NAME="akmod-${ITEM}-*.fc${RELEASE}.${ARCH}"
    
    # Temporarily disable exit on error
    set +e
    
    # Capture both standard output and standard error
    INSTALL_OUT=$(dnf5 install -y "$PKG_NAME" 2>&1)
    INSTALL_EXIT=$?
    
    # Re-enable exit on error
    set -e
    
    # Print the output so it remains visible in your image build logs
    echo "$INSTALL_OUT"
    
    # Check if the install failed specifically because it couldn't find the package
    if [ $INSTALL_EXIT -ne 0 ] && echo "$INSTALL_OUT" | grep -q "No match for argument"; then
        echo "ERROR: Package $PKG_NAME could not be found."
        # TODO: remove build failure. Commented out for testing. 
        # exit 1
    fi
done

dnf5 -y copr disable ublue-os/akmods

#### looking-glass-kvmfr

dnf5 -y copr enable hikariknight/looking-glass-kvmfr

set +e
KVMFR_OUT=$(dnf5 -y install akmod-kvmfr 2>&1)
KVMFR_EXIT=$?
set -e

echo "$KVMFR_OUT"

if [ $KVMFR_EXIT -ne 0 ] && echo "$KVMFR_OUT" | grep -q "No match for argument"; then
    echo "ERROR: akmod-kvmfr could not be found."
    exit 1
fi

dnf5 -y copr disable hikariknight/looking-glass-kvmfr

#### SENTRY-XONE (Linux kernel driver for Xbox One and Xbox Series X|S accessories)

dnf5 -y copr enable sentry/xone

set +e
XPAD_OUT=$(dnf5 -y install xpad-noone akmod-xpad-noone 2>&1)
XPAD_EXIT=$?
set -e

echo "$XPAD_OUT"

if [ $XPAD_EXIT -ne 0 ] && echo "$XPAD_OUT" | grep -q "No match for argument"; then
    echo "ERROR: xpad-noone or akmod-xpad-noone could not be found."
    # TODO: remove build failure. Commented out for testing. 
    # exit 1
fi

dnf5 -y copr disable sentry/xone

#### regen initramfs with akmods

CC=clang LD=ld.lld LLVM=1 KCFLAGS="-Wno-error -Wno-sometimes-uninitialized" akmods --force --kernels "${KERNEL}"
depmod -a ${KERNEL}
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "${KERNEL}" --reproducible -v --add ostree -f "/lib/modules/${KERNEL}/initramfs.img"
chmod 0600 "/lib/modules/${KERNEL}/initramfs.img"

# Restore kernel install
mv -f 05-rpmostree.install.bak 05-rpmostree.install \
&& mv -f 50-dracut.install.bak 50-dracut.install
cd -

# Remove kernel development packages after build
dnf5 versionlock delete kernel-cachyos-lto-devel kernel-cachyos-lto-devel-matched
dnf5 -y remove kernel-cachyos-lto-devel kernel-cachyos-lto-devel-matched

# Clean up akmods and dracut leftovers
rm -rf /var/cache/akmods
rm -rf /var/cache/kvmfr
rm -rf /var/tmp/*