#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 file1.mkv [file2.mkv ...]"
  exit 1
fi

for input_file in "$@"; do
  [[ -f "$input_file" ]] || { echo "Skip: $in (not a file)"; continue; }
  ext="${input_file##*.}"
  [[ "${ext,,}" == "mkv" ]] || { echo "Skip: $input_file (not .mkv)"; continue; }

  tmp="${input_file%.*}.nosubs.tmp.mkv"

  # Copy everythinput_fileg but subtitle streams; keep chapters & metadata
  ffmpeg -hide_banner -loglevel error -i "$input_file" \
    -map 0 \
    -map -0:s \
    -map_chapters 0 \
    -map_metadata 0 \
    -c copy \
    "$tmp"

  mv -f -- "$tmp" "$input_file"
  echo "Subtitles removed: $input_file"
done

