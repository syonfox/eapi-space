#!/bin/bash

# Usage check
if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-mod-folder>"
  exit 1
fi

mod_dir="$1"

# Ensure mod directory exists
if [ ! -d "$mod_dir" ]; then
  echo "Error: '$mod_dir' does not exist or is not a directory"
  exit 1
fi

# Get the current git branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Ensure the '_release' directory exists
release_dir="_release"
mkdir -p "$release_dir"

# Get the current date
current_date=$(date +%Y_%m_%d)

# Define the release file name (absolute path avoids cd issues)
release_file="$(pwd)/${release_dir}/syon_mod_${current_branch}_${current_date}.zip"

# Create zip from inside the mod directory so contents are at root
(
  cd "$mod_dir" || exit 1

  non_underscore_items=()
  for item in *; do
    if [[ ! "$item" =~ ^_ ]]; then
      non_underscore_items+=("$item")
    fi
  done

  zip -r "$release_file" "${non_underscore_items[@]}"
)

echo "Created release archive: $release_file"

echo "$ cp $release_file /home/user/.pioneer/mods/"
read -p "Do you want to install to /home/user/.pioneer/mods/? [y/N] " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Installing $release_file..."
  cp "$release_file" "/home/user/.pioneer/mods/"
  echo "Install complete."
else
  echo "Install skipped."
fi