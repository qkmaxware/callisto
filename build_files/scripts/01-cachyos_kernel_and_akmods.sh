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

# Intercept akmods so it doesn't fail RPM %post scripts running as root
if [ -x /usr/sbin/akmods ]; then
    mv /usr/sbin/akmods /usr/sbin/akmods.bak
    ln -s /usr/bin/true /usr/sbin/akmods
fi

#### CACHY OS KERNEL

# Install standard CachyOS kernel
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra 
rm -rf /lib/modules/* # Remove kernel files that remain

dnf5 -y install \
    kernel-cachyos \
    kernel-cachyos-core \
    kernel-cachyos-modules \
    kernel-cachyos-devel \
    kernel-cachyos-devel-matched --allowerasing
dnf5 versionlock add \
    kernel-cachyos \
    kernel-cachyos-core \
    kernel-cachyos-modules \
    kernel-cachyos-devel \
    kernel-cachyos-devel-matched
dnf5 -y copr disable bieszczaders/kernel-cachyos

RELEASE=$(/usr/bin/rpm -E %fedora)
ARCH=$(/usr/bin/rpm -E '%_arch')

# Safely grab the exact kernel version string directly from the installed devel headers
KERNEL=$(ls /usr/src/kernels/ | head -n 1)

#### AKMODS

# Install the RPMFusion repos for akmods
dnf5 -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

KMOD_PACKAGES=(
    "akmod-v4l2loopback"
    "akmod-intel-ipu6"
)

for ITEM in "${KMOD_PACKAGES[@]}"; do
    set +e
    INSTALL_OUT=$(dnf5 install -y "$ITEM" 2>&1)
    INSTALL_EXIT=$?
    set -e

    echo "$INSTALL_OUT"
    
    if [ $INSTALL_EXIT -ne 0 ]; then
        echo "========================================================="
        echo "WARNING: dnf5 failed to install $ITEM!"
        echo "It will be skipped in this build. See error above."
        echo "========================================================="
    fi
done

# Remove the RPMFusion repos
dnf5 -y remove rpmfusion-free-release-$(rpm -E %fedora)
dnf5 -y remove rpmfusion-nonfree-release-$(rpm -E %fedora)

#### Negativo xpadneo akmod

set +e
INSTALL_OUT=$(sudo dnf5 -y install akmod-xpadneo \
  --repofrompath='negativo17,https://negativo17.org/repos/multimedia/fedora-$releasever/$basearch/' \
  --setopt="negativo17.gpgkey=https://negativo17.org/repos/RPM-GPG-KEY-slaanesh")
INSTALL_EXIT=$?
set -e

if [ $INSTALL_EXIT -ne 0 ]; then
    echo "========================================================="
    echo "WARNING: dnf5 failed to install akmod-xpadneo!"
    echo "It will be skipped in this build. See error above."
    echo "========================================================="
fi

#### COPR akmods

# Enable COPR repos
COPR_REPOS=(
    "ublue-os/akmods"
    "hikariknight/looking-glass-kvmfr"
    "ssweeny/system76-hwe"
    "gladion136/tuxedo-drivers-kmod"
    "abn/amd-isp4-capture-kmod"
)

for ITEM in "${COPR_REPOS[@]}"; do
    echo "Enabling COPR: $ITEM..."
    dnf5 -y copr enable "$ITEM"
done

# List of akmods to build
tee "/tmp/akmods" > /dev/null <<EOF
akmod-openrazer | ublue-os/akmods
akmod-framework-laptop | ublue-os/akmods
akmod-zenergy | ublue-os/akmods
akmod-ryzen-smu | ublue-os/akmods
akmod-xone | ublue-os/akmods
akmod-bmi160 | ublue-os/akmods
akmod-asus-wmi | ublue-os/akmods
akmod-nct6687d | ublue-os/akmods
akmod-rtl88xxau | ublue-os/akmods
akmod-rtl8814au | ublue-os/akmods
akmod-openrgb | ublue-os/akmods
akmod-zenpower3 | ublue-os/akmods
akmod-kvmfr | hikariknight/looking-glass-kvmfr
akmod-system76-io | ssweeny/system76-hwe
akmod-system76-driver | ssweeny/system76-hwe
akmod-tuxedo-drivers | gladion136/tuxedo-drivers-kmod
amd-isp4-capture-kmod | abn/amd-isp4-capture-kmod
EOF

while IFS=" |" read -r PKG_NAME REPO || [[ -n "$PKG_NAME" ]]; do
    [[ -z "$PKG_NAME" ]] && continue

    COPR_ID="copr:copr.fedorainfracloud.org:${REPO//\//:}"
    echo "Processing: $PKG_NAME (from repo: $COPR_ID)..."
    
    set +e
    INSTALL_OUT=$(dnf5 install -y --best --disablerepo="copr:*" --enablerepo="$COPR_ID" "$PKG_NAME" 2>&1)
    INSTALL_EXIT=$?
    set -e
    
    echo "$INSTALL_OUT"
    
    if [ $INSTALL_EXIT -ne 0 ]; then
        echo "========================================================="
        echo "WARNING: dnf5 failed to install $PKG_NAME!"
        echo "It will be skipped in this build. See error above."
        echo "========================================================="
    fi
done < "/tmp/akmods"

rm -rf /tmp/akmods

#### regen initramfs with akmods

# Restore the real akmods binary
if [ -e /usr/sbin/akmods.bak ]; then
    rm -f /usr/sbin/akmods
    mv /usr/sbin/akmods.bak /usr/sbin/akmods
fi

# Install compiler toolchain
dnf5 -y install clang lld llvm compiler-rt

# Export variables so they carry into the rpmbuild subshell
export CC=clang
export LD=ld.lld
export LLVM=1
export KCFLAGS="-Wno-error -Wno-sometimes-uninitialized"

akmods --force --kernels "${KERNEL}"

# Remove compiler toolchain to prevent image bloat
dnf5 -y remove clang lld llvm compiler-rt

depmod -a ${KERNEL}
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "${KERNEL}" --reproducible -v --add ostree -f "/lib/modules/${KERNEL}/initramfs.img"
chmod 0600 "/lib/modules/${KERNEL}/initramfs.img"

# Restore kernel install
mv -f 05-rpmostree.install.bak 05-rpmostree.install \
&& mv -f 50-dracut.install.bak 50-dracut.install
cd -

# Disable KMOD repos
for ITEM in "${COPR_REPOS[@]}"; do
    echo "Disabling COPR: $ITEM..."
    dnf5 -y copr disable "$ITEM"
done

# Remove kernel development packages after build
dnf5 versionlock delete kernel-cachyos-devel kernel-cachyos-devel-matched
dnf5 -y remove kernel-cachyos-devel kernel-cachyos-devel-matched

# Clean up akmods and dracut leftovers
rm -rf /var/cache/akmods
rm -rf /var/cache/kvmfr
rm -rf /var/tmp/*