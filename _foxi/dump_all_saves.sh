#!/bin/bash

# Define variables
SAVEGAME_PATH="../../../git/pioneer/savegamedump"
SAVEFILES_DIR="../../savefiles"
OUTPUT_DIR="mods/eapi-space/saves"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Loop through all files in the savefiles directory
for savefile in "$SAVEFILES_DIR"/*; do
  # Extract the base name of the savefile (without directory path)
  savefile_name=$(basename "$savefile")

  # Define the output file path
  output_file="$OUTPUT_DIR/${savefile_name}.json"

  # Dump the savegame
  echo "Dumping $savefile_name..."
  $SAVEGAME_PATH --pretty savefiles/$savefile_name $output_file

  # Check if the command was successful
  if [ $? -eq 0 ]; then
    echo "Successfully dumped $savefile_name to $output_file"
  else
    echo "Failed to dump $savefile_name"
  fi
done

echo "All save files processed."
