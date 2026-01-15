#!/bin/bash
echo "AJR btop installer"
echo "------------------"
if [ "$1" = "x64" ]; then
    echo ">>> Command line x64 option selected"
    echo
    arch_pattern="x86_64"
elif [ "$1" = "aarch64" ]; then
    echo ">>> Command line aarch64 option selected"
    echo
    arch_pattern="aarch64"
else
    echo "No architecture selected when running script, please select either x64 or aarch64."
    echo "  1. x64"
    echo "  2. aarch64"
    echo
    read -p "Enter the number of the architecture you want to install: " architecture_number
    if [ "$architecture_number" = "1" ]; then
        echo ">>> x64 option selected"
        echo
        arch_pattern="x86_64"
    elif [ "$architecture_number" = "2" ]; then
        echo ">>> aarch64 option selected"
        echo
        arch_pattern="aarch64"
    else
        echo
        echo ">>> Invalid option selected - exiting."
        exit 1
    fi
fi
echo
echo ">>> Installing dependencies..."
sudo apt install -y bzip2 make
echo ">>> Fetching latest release of btop..."

# Extract the download URL directly from the GitHub API response
# Use jq to parse JSON properly, fall back to grep if jq not available
download_url=""
filename=""

if command -v jq &> /dev/null; then
    # Get both the filename and download URL using jq
    jq_output=$(curl -s https://api.github.com/repos/aristocratos/btop/releases/latest \
        | jq -r ".assets[] | select(.name | contains(\"$arch_pattern\")) | \"\(.name)|\(.browser_download_url)\"" | head -1)
    filename=$(echo "$jq_output" | cut -d'|' -f1)
    download_url=$(echo "$jq_output" | cut -d'|' -f2)
else
    # Fallback: grep-based parsing for systems without jq
    api_response=$(curl -s https://api.github.com/repos/aristocratos/btop/releases/latest)
    filename=$(echo "$api_response" | grep '"name"' | grep "$arch_pattern" | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    download_url=$(echo "$api_response" | grep "browser_download_url" | grep "$arch_pattern" | head -1 | sed 's/.*"\(https[^"]*\)".*/\1/')
fi

if [ -z "$download_url" ] || [ -z "$filename" ]; then
    echo ">>> Error: Could not find download URL for architecture: $arch_pattern"
    echo ">>> Debugging: Checking available assets..."
    if command -v jq &> /dev/null; then
        curl -s https://api.github.com/repos/aristocratos/btop/releases/latest | jq -r '.assets[].name'
    else
        curl -s https://api.github.com/repos/aristocratos/btop/releases/latest | grep '"name"'
    fi
    exit 1
fi

echo ">>> Downloading: $filename"
wget "$download_url"

if [ ! -f "$filename" ]; then
    echo ">>> Error: Download failed - file not found."
    exit 1
fi

echo ">>> Extracting and installing btop..."
tar -xjf "$filename"
cd btop
./install.sh
echo ">>> Cleaning up..."
cd ..
rm "$filename"
rm -rf btop
echo ">>> Installation complete."
