#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable deltacopy/darkly
dnf5 -y install darkly
dnf5 -y copr disable deltacopy/darkly

mkdir -p /usr/share/plasma/look-and-feel/Callisto
cp -rf /ctx/files/usr/share/plasma/look-and-feel/Callisto /usr/share/plasma/look-and-feel/

kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage Callisto

# Rip out default installed wallpapers (minus a few special ones)
dnf5 -y remove plasma-workspace-wallpapers

# Download my astro-images as wallpapers
JSON_URL="https://qkmaxware.github.io/astrophotography/api/targets.json"
OUTPUT_DIR="/usr/share/wallpapers/Callisto"
BASE_URL="https://qkmaxware.github.io"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Fetch JSON and process
curl -s "$JSON_URL" | jq -r '.[] | @base64' | while read -r item; do
    # Helper to decode each object
    _jq() {
        echo "$item" | base64 --decode | jq -r "$1"
    }
	
	rel_path=$(_jq '.url')
    title=$(_jq '.title')
	
	# Skip empty/null
    [[ -z "$rel_path" || "$rel_path" == "null" ]] && continue
    [[ -z "$title" || "$title" == "null" ]] && title="untitled"
	
	# Sanitize title for folder name
    safe_title=$(echo "$title" | tr '[:space:]' '_' | tr -cd '[:alnum:]_-')
	
    # Build full URL
    full_url="${BASE_URL}${rel_path}"

    # Extract filename
    filename=$(basename "$rel_path")
	
	# Extract extension
    ext="${filename##*.}"
	
	# Create subdirectory
    target_dir="$OUTPUT_DIR/$safe_title"
    mkdir -p "$target_dir"

	output_file="$target_dir/wallpaper.${ext}"

    echo "Downloading $full_url -> $output_file"

    curl -s -L "$full_url" -o "$output_file"
done