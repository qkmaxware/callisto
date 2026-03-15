#!/usr/bin/env bash

set -ouex pipefail

IMAGE_VENDOR="qkmaxware"
IMAGE_NAME="callisto"
IMAGE_PRETTY_NAME="Callisto"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/qkmaxware/callisto"
DOCUMENTATION_URL="https://github.com/qkmaxware/callisto/wiki"
SUPPORT_URL="https://github.com/qkmaxware/callisto/issues"
BUG_SUPPORT_URL="https://github.com/qkmaxware/callisto/issues"
VERSION_CODENAME=""

FEDORA_MAJOR_VERSION=$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)
BASE_IMAGE_NAME="Kinoite $FEDORA_MAJOR_VERSION"

# OS Release File
mkdir -p /usr/share/icons/hicolor/scalable/
cp ctx/files/usr/share/icons/hicolor/scalable/distro-logo.svg /usr/share/icons/hicolor/scalable/distro-logo.svg
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (FROM Fedora ${BASE_IMAGE_NAME^})\"/" /usr/lib/os-release
sed -i "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" /usr/lib/os-release
sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" /usr/lib/os-release
sed -i "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^CPE_NAME=\"cpe:/o:qkmaxware:callisto|CPE_NAME=\"cpe:/o:qkmaxware:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
sed -i "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${IMAGE_PRETTY_NAME,}\"/" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" /usr/lib/os-release
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release
sed -i "s/^VERSION_CODENAME=.*/VERSION_CODENAME=${VERSION_CODENAME,,}/" /usr/lib/os-release
sed -i 's/^LOGO=.*/LOGO=distro-logo/' /usr/lib/os-release

#if [[ -n "${SHA_HEAD_SHORT:-}" ]]; then
#  echo "BUILD_ID=\"$SHA_HEAD_SHORT\"" >> /usr/lib/os-release
#fi

# Fix issues caused by ID no longer being fedora
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg
