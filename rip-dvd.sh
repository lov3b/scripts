#!/usr/bin/env bash

set -euo pipefail

quality=18

usage() {
  echo "Usage: $0 [-q quality] <title> [<title> ...]" >&2
}

while getopts ":q:h" opt; do
  case "$opt" in
    q) quality="$OPTARG" ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Error: invalid option -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Error: option -$OPTARG requires an argument" >&2
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

for t in "$@"; do
  HandBrakeCLI -i /dev/sr0 -t "$t" -o "Title$(printf '%02d' "$t").mkv" -f av_mkv \
    -e nvenc_h264 -q "$quality" --encoder-preset slow \
    --comb-detect --decomb \
    --all-audio -E copy \
    --audio-copy-mask aac,ac3,eac3,truehd,dts,dtshd,mp2,mp3,opus,vorbis,flac,alac \
    --audio-fallback ac3 \
    --all-subtitles --subtitle-default=none \
    --markers --verbose=1
done
