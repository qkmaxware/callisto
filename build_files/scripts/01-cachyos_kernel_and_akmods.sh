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

#### PREPARE NON-ROOT BUILD ENVIRONMENT

# Install required build tools
dnf5 -y install mock rpm-build akmods gcc

# Create a temporary non-root user for safely building kernel modules
useradd -m builder
usermod -aG mock builder

# Create a directory to hold the downloaded source RPMs
mkdir -p /tmp/src_rpms
cd /tmp/src_rpms

#### FETCH RPMFUSION AKMODS

# Install the RPMFusion repos for akmods
dnf5 -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

KMOD_PACKAGES=(
    "akmod-v4l2loopback"
    "akmod-intel-ipu6"
)

for ITEM in "${KMOD_PACKAGES[@]}"; do
    set +e
    # Download the SOURCE package instead of installing it
    INSTALL_OUT=$(dnf5 download --source "$ITEM" 2>&1)
    INSTALL_EXIT=$?
    set -e

    if [ $INSTALL_EXIT -ne 0 ]; then
        echo "========================================================="
        echo "WARNING: Failed to download source for $ITEM!"
        echo "$INSTALL_OUT"
        echo "========================================================="
    fi
done

# Remove the RPMFusion repos
dnf5 -y remove rpmfusion-free-release-$(rpm -E %fedora)
dnf5 -y remove rpmfusion-nonfree-release-$(rpm -E %fedora)

#### FETCH NEGATIVO AKMODS

set +e
INSTALL_OUT=$(dnf5 download --source akmod-xpadneo \
  --repofrompath='negativo17,https://negativo17.org/repos/multimedia/fedora-$releasever/$basearch/' \
  --setopt="negativo17.gpgkey=https://negativo17.org/repos/RPM-GPG-KEY-slaanesh" 2>&1)
INSTALL_EXIT=$?
set -e

if [ $INSTALL_EXIT -ne 0 ]; then
    echo "========================================================="
    echo "WARNING: Failed to download source for akmod-xpadneo!"
    echo "$INSTALL_OUT"
    echo "========================================================="
fi

#### FETCH COPR AKMODS

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
tee "/tmp/akmods_list" > /dev/null <<EOF
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
    echo "Fetching source for: $PKG_NAME (from repo: $COPR_ID)..."
    
    set +e
    INSTALL_OUT=$(dnf5 download --source --disablerepo="copr:*" --enablerepo="$COPR_ID" "$PKG_NAME" 2>&1)
    INSTALL_EXIT=$?
    set -e
    
    if [ $INSTALL_EXIT -ne 0 ]; then
        echo "========================================================="
        echo "WARNING: Failed to download source for $PKG_NAME!"
        echo "$INSTALL_OUT"
        echo "========================================================="
    fi
done < "/tmp/akmods_list"

rm -f "/tmp/akmods_list"

#### COMPILE ALL AKMODS AS NON-ROOT USER

# Give the builder user ownership of the downloaded source RPMs
chown -R builder:builder /tmp/src_rpms

for SRC_RPM in /tmp/src_rpms/*.src.rpm; do
    # Skip if the directory is empty (no files matched)
    [ -e "$SRC_RPM" ] || continue
    
    echo "Building kernel module from: $(basename "$SRC_RPM")..."
    
    set +e
    sudo -u builder akmodsbuild --target x86_64 --kernels "${KERNEL}" "$SRC_RPM"
    BUILD_EXIT=$?
    set -e

    if [ $BUILD_EXIT -ne 0 ]; then
        echo "========================================================="
        echo "WARNING: akmodsbuild failed for $(basename "$SRC_RPM")!"
        echo "It will be skipped in this build."
        echo "========================================================="
    fi
done

#### INSTALL COMPILED KMODS

# Check if any modules actually compiled successfully
if ls /home/builder/rpmbuild/RPMS/x86_64/kmod-*.rpm 1> /dev/null 2>&1; then
    echo "Installing compiled kernel modules..."
    dnf5 -y install /home/builder/rpmbuild/RPMS/x86_64/kmod-*.rpm
else
    echo "WARNING: No kernel modules were successfully built."
fi

#### CLEANUP BUILD ENVIRONMENT

cd /
rm -rf /tmp/src_rpms
userdel -r builder
# Remove build tools to prevent image bloat
dnf5 -y remove mock rpm-build akmods gcc

#### REGENERATE INITRAMFS

depmod -a ${KERNEL}
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "${KERNEL}" --reproducible -v --add ostree -f "/lib/modules/${KERNEL}/initramfs.img"
chmod 0600 "/lib/modules/${KERNEL}/initramfs.img"

# Restore kernel install shims
cd /usr/lib/kernel/install.d \
&& mv -f 05-rpmostree.install.bak 05-rpmostree.install \
&& mv -f 50-dracut.install.bak 50-dracut.install
cd -

# Disable COPR repos
for ITEM in "${COPR_REPOS[@]}"; do
    echo "Disabling COPR: $ITEM..."
    dnf5 -y copr disable "$ITEM"
done

# Remove kernel development packages after build
dnf5 versionlock delete kernel-cachyos-devel kernel-cachyos-devel-matched
dnf5 -y remove kernel-cachyos-devel kernel-cachyos-devel-matched

# Clean up dracut leftovers
rm -rf /var/tmp/*