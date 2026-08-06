#!/bin/bash

# Usage check
if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-mod-folder> [y/n]"
  echo "Options: answer [y]es or [n]o to install the modt to .pioneer folder"
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

bash ./gen_release_page.sh $release_file


pioneer_mod_folder=/home/user/.pioneer/mods/


if [ -z "$2" ]; then
  read -r -p "Do you want to install $release_file to $pioneer_mod_folder? [y/N] " answer
else
  answer="$2"
  echo "Pre input answer: $answer"
fi

[[ "$answer" =~ ^[Yy]$ ]] || exit 0

echo "Installing $release_file..."
cp "$release_file" "$pioneer_mod_folder"
echo "Install complete."