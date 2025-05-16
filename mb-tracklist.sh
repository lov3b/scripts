#!/usr/bin/env bash
# Usage: ./mb-tracklist.sh [directory_with_flacs]
set -euo pipefail
dir="${1:-.}"

# Choose duration tool: ffprobe (preferred) or soxi
have_ffprobe=$(command -v ffprobe || true)
have_soxi=$(command -v soxi || true)
if [[ -n "$have_ffprobe" ]]; then
  get_seconds() { ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$1"; }
elif [[ -n "$have_soxi" ]]; then
  get_seconds() { soxi -D "$1"; }
else
  echo "Need ffprobe (ffmpeg) or soxi (sox) for durations." >&2
  exit 1
fi

shopt -s nullglob
files=("$dir"/*.flac)
if (( ${#files[@]} == 0 )); then
  echo "No .flac files found in: $dir" >&2
  exit 1
fi

# Collect: TRACKNUMBER | TITLE | mm:ss
tmp=$(mktemp)
for f in "${files[@]}"; do
  tn=$(metaflac --show-tag=TRACKNUMBER "$f" | sed 's/.*=//' | sed 's/^0*//')
  title=$(metaflac --show-tag=TITLE "$f" | sed 's/.*=//')
  # fallbacks
  [[ -z "$tn" ]] && tn=0
  [[ -z "$title" ]] && title=$(basename "$f" .flac)

  dur=$(get_seconds "$f")
  # round to nearest second and format mm:ss
  total=$(printf "%.0f" "$dur")
  mm=$(( total / 60 ))
  ss=$(( total % 60 ))
  len=$(printf "%d:%02d" "$mm" "$ss")

  printf "%05d\t%s\t%s\n" "$tn" "$title" "$len" >> "$tmp"
done

# Sort by track number and emit MusicBrainz-friendly lines:
LC_ALL=C sort -n "$tmp" | awk -F'\t' '{printf "%d. %s\t%s\n", $1+0, $2, $3}'
rm -f "$tmp"
