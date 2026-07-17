#!/usr/bin/env bash
set -euo pipefail

echo "AJR btop installer"
echo "------------------"

select_arch() {
  case "${1:-}" in
    x64)
      echo ">>> Command line x64 option selected"
      echo
      arch_pattern="x86_64"
      ;;
    aarch64)
      echo ">>> Command line aarch64 option selected"
      echo
      arch_pattern="aarch64"
      ;;
    "")
      local detected_arch
      detected_arch="$(uname -m)"
      case "$detected_arch" in
        x86_64|amd64)
          echo ">>> Detected architecture: $detected_arch"
          read -r -p "Use detected x64 architecture? [Y/n]: " reply
          case "${reply:-Y}" in
            [Nn]*) ;;
            *)
              arch_pattern="x86_64"
              return 0
              ;;
          esac
          ;;
        aarch64|arm64)
          echo ">>> Detected architecture: $detected_arch"
          read -r -p "Use detected aarch64 architecture? [Y/n]: " reply
          case "${reply:-Y}" in
            [Nn]*) ;;
            *)
              arch_pattern="aarch64"
              return 0
              ;;
          esac
          ;;
      esac

      echo "No architecture selected when running script, please select either x64 or aarch64."
      echo " 1. x64"
      echo " 2. aarch64"
      echo
      read -r -p "Enter the number of the architecture you want to install: " architecture_number
      case "$architecture_number" in
        1)
          echo ">>> x64 option selected"
          echo
          arch_pattern="x86_64"
          ;;
        2)
          echo ">>> aarch64 option selected"
          echo
          arch_pattern="aarch64"
          ;;
        *)
          echo
          echo ">>> Invalid option selected - exiting."
          exit 1
          ;;
      esac
      ;;
    *)
      echo ">>> Invalid argument: $1"
      echo ">>> Use: $0 [x64|aarch64]"
      exit 1
      ;;
  esac
}

select_arch "${1:-}"

echo
echo ">>> Installing dependencies..."
sudo apt update
sudo apt install -y curl wget jq bzip2 tar make

echo ">>> Fetching latest release of btop..."
api_json="$(curl -fsSL https://api.github.com/repos/aristocratos/btop/releases/latest)"

download_url=""
filename=""

if command -v jq >/dev/null 2>&1; then
  asset="$(printf '%s\n' "$api_json" | jq -r ".assets[] | select(.name | contains(\"$arch_pattern\")) | .name + \"|\" + .browser_download_url" | head -n 1)"
  if [ -n "$asset" ]; then
    filename="${asset%%|*}"
    download_url="${asset#*|}"
  fi
else
  filename="$(printf '%s\n' "$api_json" | grep '"name"' | grep "$arch_pattern" | head -n 1 | sed 's/.*"\([^"]*\)".*/\1/')"
  download_url="$(printf '%s\n' "$api_json" | grep '"browser_download_url"' | grep "$arch_pattern" | head -n 1 | sed 's/.*"\(https[^"]*\)".*/\1/')"
fi

if [ -z "$download_url" ] || [ -z "$filename" ]; then
  echo ">>> Error: Could not find download URL for architecture: $arch_pattern"
  echo ">>> Debugging: Checking available assets..."
  if command -v jq >/dev/null 2>&1; then
    printf '%s\n' "$api_json" | jq -r '.assets[].name'
  else
    printf '%s\n' "$api_json" | grep '"name"'
  fi
  exit 1
fi

workdir="$(mktemp -d)"
archive_path="$workdir/$filename"
trap 'rm -rf "$workdir"' EXIT

echo ">>> Downloading: $filename"
wget -O "$archive_path" "$download_url"

if [ ! -f "$archive_path" ]; then
  echo ">>> Error: Download failed - file not found."
  exit 1
fi

echo ">>> Extracting and installing btop..."
tar -xf "$archive_path" -C "$workdir"

install_dir="$(find "$workdir" -type f -name install.sh -exec dirname {} \; | head -n 1)"

if [ -z "$install_dir" ]; then
  echo ">>> Error: install.sh not found in extracted archive."
  exit 1
fi

cd "$install_dir"
sudo ./install.sh

echo ">>> Cleaning up..."
echo ">>> Installation complete."
