#!/bin/bash

# Get the current git branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Ensure the '_release' directory exists
release_dir="_release"
mkdir -p "$release_dir"

# Get the current date in YYYY_MM_DD format
current_date=$(date +%Y_%m_%d)

# Define the release file name
release_file="${release_dir}/syon_mod_${current_branch}_${current_date}.zip"

# Collect all non-underscore files and directories
non_underscore_items=()
for item in *; do
  if [[ ! "$item" =~ ^_ ]]; then
    non_underscore_items+=("$item")
  fi
done

# Create the zip archive
zip -r "$release_file" "${non_underscore_items[@]}"
echo "Created release archive: $release_file"
