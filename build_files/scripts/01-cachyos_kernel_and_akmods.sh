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

RELEASE=$(/usr/bin/rpm -E %fedora)
ARCH=$(/usr/bin/rpm -E '%_arch')
KERNEL=$(dnf5 list kernel-cachyos-lto -q | awk '/kernel-cachyos-lto/ {print $2}' | head -n 1 | cut -d'-' -f1)-cachyos1.lto.fc${RELEASE}.${ARCH}

#### AKMODS

# Install the RPMFusion repos for akmods
dnf5 -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

KMOD_PACKAGES=(
    "akmod-v4l2loopback"
    "akmod-intel-ipu6"
)

for ITEM in "${KMOD_PACKAGES[@]}"; do
    
    # Temporarily disable exit on error
    set +e
    
    # Capture both standard output and standard error
    # The --repo flag now uses the properly formatted Copr ID
    INSTALL_OUT=$(dnf5 install -y "$ITEM" 2>&1)
    INSTALL_EXIT=$?
    
    # Re-enable exit on error
    set -e

    # Print the output so it remains visible in your image build logs
    echo "$INSTALL_OUT"
    
    # Check if the install failed specifically because it couldn't find the package
    if [ $INSTALL_EXIT -ne 0 ] && echo "$INSTALL_OUT" | grep -q "No match for argument"; then
        echo "ERROR: Package $ITEM could not be found in default installed repos."
        exit 1
    fi
done

# Remove the RPMFusion repos
dnf5 -y remove rpmfusion-free-release-$(rpm -E %fedora)
dnf5 -y remove rpmfusion-nonfree-release-$(rpm -E %fedora)

#### Negativo xpadneo akmod

# Temporarily disable exit on error
set +e

# Install the negativo17 fedora multimedia repos
INSTALL_OUT=$(sudo dnf5 -y install akmod-xpadneo \
  --repofrompath='negativo17,https://negativo17.org/repos/multimedia/fedora-$releasever/$basearch/' \
  --setopt="negativo17.gpgkey=https://negativo17.org/repos/RPM-GPG-KEY-slaanesh")
INSTALL_EXIT=$?

# Re-enable exit on error
set -e

if [ $INSTALL_EXIT -ne 0 ] && echo "$INSTALL_OUT" | grep -q "No match for argument"; then
    echo "ERROR: Package akmod-xpadneo could not be found in default installed repos."
    exit 1
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
# akmod-bmi160 currently fails to compile using LTO kernel
tee "/tmp/akmods" > /dev/null <<EOF
akmod-openrazer | ublue-os/akmods
akmod-framework-laptop | ublue-os/akmods
akmod-zenergy | ublue-os/akmods
akmod-ryzen-smu | ublue-os/akmods
akmod-xone | ublue-os/akmods
akmod-kvmfr | hikariknight/looking-glass-kvmfr
akmod-system76-io | ssweeny/system76-hwe
akmod-system76-driver | ssweeny/system76-hwe
akmod-tuxedo-drivers | gladion136/tuxedo-drivers-kmod
amd-isp4-capture-kmod | abn/amd-isp4-capture-kmod
akmod-i915-sriov | Matte23/akmod-i915-sriov
EOF

# Read through the file line by line, using space and pipe as delimiters
while IFS=" |" read -r PKG_NAME REPO || [[ -n "$PKG_NAME" ]]; do
    # Skip any empty lines
    [[ -z "$PKG_NAME" ]] && continue

    # Transform "user/project" into "copr:copr.fedorainfracloud.org:user:project"
    COPR_ID="copr:copr.fedorainfracloud.org:${REPO//\//:}"

    echo "Processing: $PKG_NAME (from repo: $COPR_ID)..."
    
    # Temporarily disable exit on error
    set +e
    
    # Capture both standard output and standard error
    # Disable all other repos for 
    INSTALL_OUT=$(dnf5 install -y --best --disablerepo="copr:*" --enablerepo="$COPR_ID" "$PKG_NAME" 2>&1)
    INSTALL_EXIT=$?
    
    # Re-enable exit on error
    set -e
    
    # Print the output so it remains visible in your image build logs
    echo "$INSTALL_OUT"
    
    # Check if the install failed specifically because it couldn't find the package
    if [ $INSTALL_EXIT -ne 0 ] && echo "$INSTALL_OUT" | grep -q "No match for argument"; then
        echo "ERROR: Package $PKG_NAME could not be found in repo $COPR_ID."
        exit 1
    fi
done < "/tmp/akmods"

rm -rf /tmp/akmods

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

# Disable KMOD repos
for ITEM in "${COPR_REPOS[@]}"; do
    echo "Enabling COPR: $ITEM..."
done

# Remove kernel development packages after build
dnf5 versionlock delete kernel-cachyos-lto-devel kernel-cachyos-lto-devel-matched
dnf5 -y remove kernel-cachyos-lto-devel kernel-cachyos-lto-devel-matched

# Clean up akmods and dracut leftovers
rm -rf /var/cache/akmods
rm -rf /var/cache/kvmfr
rm -rf /var/tmp/*