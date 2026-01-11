#!/bin/bash

# -----------------------------------------
# Multi‑folder Docker update script
# -----------------------------------------
# Behavior:
#  - Pull updated images
#  - Recreate containers with docker compose up -d
#  - Prune unused images
#  - Accept folders as arguments OR read from folders.txt
# -----------------------------------------

# Path to the folder list file
FOLDER_LIST="/home/user/projectdocker/folders.txt"

# Determine target folders
if [ "$#" -gt 0 ]; then
    TARGETS=("$@")
else
    if [ ! -f "$FOLDER_LIST" ]; then
        echo "No arguments provided and $FOLDER_LIST not found."
        exit 1
    fi

    mapfile -t TARGETS < "$FOLDER_LIST"
fi

# Loop through each folder
for DIR in "${TARGETS[@]}"; do
    echo "----------------------------------------"
    echo "Updating Docker stack in: $DIR"
    echo "----------------------------------------"

    if [ ! -d "$DIR" ]; then
        echo "Skipping: $DIR (not a directory)"
        echo
        continue
    fi

    cd "$DIR" || continue

    # Pull updated images
    docker compose pull

    # Recreate containers
    docker compose up -d

    # Clean unused images
    docker image prune -f

    echo "Done updating: $DIR"
    echo
done
