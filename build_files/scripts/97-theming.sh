#!/bin/bash

set -ouex pipefail

releasever=$(rpm -E '%fedora')

# Install the darkly theme
dnf5 -y install darkly \
  --repofrompath='darkly,https://download.copr.fedorainfracloud.org/results/deltacopy/darkly/fedora-$releasever-x86_64/' \
  --setopt="darkly.gpgkey=https://download.copr.fedorainfracloud.org/results/deltacopy/darkly/pubkey.gpg"

# Install tela icon theme
git clone --depth 1 https://github.com/vinceliuice/Tela-icon-theme.git
./Tela-icon-theme/install.sh -c -d /usr/share/icons -n "Tela_Callisto"
rm -rf Tela-icon-theme

# Overwrite tela's start-here logo with callisto
for dir in /usr/share/icons/Tela_Callisto/32/status/ /usr/share/icons/Tela_Callisto/24/panel/' '/usr/share/icons/Tela_Callisto/22/panel/' '/usr/share/icons/Tela_Callisto/16/panel/'; do sudo cp -f ctx/files/usr/share/icons/hicolor/scalable/start-here.svg "$dir"; done

mkdir -p /usr/share/plasma/look-and-feel/Callisto
cp -rf /ctx/files/usr/share/plasma/look-and-feel/Callisto /usr/share/plasma/look-and-feel/

kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage Callisto

# Rip out default installed wallpapers (minus a few special ones)
dnf5 -y remove plasma-workspace-wallpapers

# Download my astro-images as wallpapers
JSON_URL="https://qkmaxware.github.io/astrophotography/api/targets.json"
OUTPUT_DIR="/usr/share/wallpapers"
BASE_URL="https://qkmaxware.github.io"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Fetch JSON and process
curl -s "$JSON_URL" | jq -r '.[] | "\(.title)\t\(.url)"' | while IFS=$'\t' read -r title rel_path; do
    
    # Skip empty/null paths
    [[ -z "$rel_path" || "$rel_path" == "null" ]] && continue
    [[ -z "$title" || "$title" == "null" ]] && title="untitled"
    
    # Sanitize title for folder name (standardizing spaces to underscores)
    safe_title=$(echo "$title" | tr '[:space:]' '_' | tr -cd '[:alnum:]_-')
    
    # Use jq to encode URL path
    encoded_rel_path=$(jq -rn --arg p "$rel_path" '$p | gsub(" "; "%20")')
    full_url="${BASE_URL}${encoded_rel_path}"

    # Extract filename and extension from the original path
    filename=$(basename "$rel_path")
    ext="${filename##*.}"
    
    # Prepare directory and file path
    root_dir="$OUTPUT_DIR/$safe_title"
    target_dir="$root_dir/contents/images"
    mkdir -p "$target_dir"
    output_file="$target_dir/1920x1080.${ext}" 

    echo "Downloading $full_url -> $output_file"

    # Download 
    curl -s -L "$full_url" -o "$output_file"
    ln -s "$output_file" "$root_dir/contents/screenshot.${ext}"

    # Create metadata file
    cat <<EOF > $root_dir/metadata.json
{
    "KPlugin": {
        "Authors": [
            { "Email": "", "Name": "qkmaxware" }
        ],
        "Id": "$safe_title",
        "Name": "$title"
    }
}
EOF
done