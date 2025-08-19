#!/bin/bash

SRC_DIR="Testsounds/converted"
DEST_DIR="Testsounds/reindexed"

if [ -z "$1" ]; then
  echo "provide initial index"
  exit 1
fi

INITIAL_INDEX=$1
INDEX=$INITIAL_INDEX

mkdir -p "$DEST_DIR"

# Find all .wav files, sort by filename (timestamp part)
find "$SRC_DIR" -type f -name "*.wav" | sort | while read -r FILE; do
  BASENAME=$(basename "$FILE")
  # Extract timestamp part (everything before '-humans.')
  TIMESTAMP=$(echo "$BASENAME" | sed -E 's/-humans\.[0-9]+\.wav$//')
  # Build new filename
  NEW_FILENAME="${TIMESTAMP}-humans.$INDEX.wav"
  cp "$FILE" "$DEST_DIR/$NEW_FILENAME"
  INDEX=$((INDEX + 1))
done