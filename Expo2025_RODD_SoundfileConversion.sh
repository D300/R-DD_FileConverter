#!/usr/bin/env zsh
# Simple .webm to .wav batch converter (48kHz, 16-bit, mono)
# All converted files are placed in a "converted" subfolder of the output directory.

set -euo pipefail  # Exit on error, unset variable, or failed pipe

# --- Usage function: prints usage info and exits if arguments are wrong ---
usage() {
  echo "Usage: $(basename "$0") [INPUT_DIR=. ] [OUTPUT_DIR=<INPUT_DIR>]"
  echo "Example: $(basename "$0") ./in ./out"
  exit 1
}

# --- Argument parsing and validation ---
[[ $# -gt 2 ]] && usage  # Allow 0-2 arguments
INPUT_DIR="${1:-.}"                  # Input directory (default: current)
OUTPUT_DIR="${2:-$INPUT_DIR}"        # Output directory (default: input dir)

# log directory paths
echo "Input Directory: $INPUT_DIR"
echo "Output Directory: $OUTPUT_DIR"

# --- Check for ffmpeg installation ---
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Error: ffmpeg not found. Install with: brew install ffmpeg" >&2
  exit 1
fi

# --- Check input directory exists, create output directory ---
[[ ! -d "$INPUT_DIR" ]] && { echo "Error: INPUT_DIR not found: $INPUT_DIR" >&2; exit 1; }

CONVERTED_DIR="${OUTPUT_DIR%/}/converted"   # Create 'converted' subfolder in output directory
mkdir -p "$CONVERTED_DIR"

# --- Find .webm files and convert them directly ---
find "$INPUT_DIR" -type f -name "*.webm" | while IFS= read -r f; do
  bn="$(basename "$f" .webm)"                # Get base filename without extension
  outpath="${CONVERTED_DIR}/${bn}.wav"       # Output path in converted folder

  echo "ffmpeg: \"$f\" -> \"$outpath\""
  ffmpeg -y -hide_banner -loglevel error \
    -i "$f" \
    -af "silenceremove=start_periods=1:start_silence=0.1:start_threshold=-40dB" \
    -ac 1 -ar 48000 -sample_fmt s16 \
    "$outpath"

  [[ -f "$outpath" ]] && echo "✓ Wrote: $outpath" || echo "✗ Failed: $outpath" >&2
done

echo "Done."  # All conversions finished