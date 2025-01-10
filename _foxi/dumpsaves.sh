#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <savefile_name>"
  exit 1
fi

# Define variables
SAVEFILE_NAME=$1
SAVEGAME_PATH="../../../git/pioneer/savegamedump"
SAVEFILE_DIR="savefiles/${SAVEFILE_NAME}"
OUTPUT_FILE="mods/eapi-space/saves/${SAVEFILE_NAME}.json"

# Run the command
$SAVEGAME_PATH --pretty $SAVEFILE_DIR $OUTPUT_FILE

# Notify the user of completion
if [ $? -eq 0 ]; then
  echo "Savegame dump completed successfully."
  echo " $OUTPUT_FILE "
else
  echo "Failed to dump the savegame."
fi
