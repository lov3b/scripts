#!/usr/bin/env bash
set -euo pipefail

main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 SOURCE.svg [OUTPUT.ico]" >&2
        exit 1
    fi

    local source="$1"
    [[ -f "$source" ]] || { echo "Source not found: $source" >&2; exit 1; }

    local -a sizes=(16 24 32 48 64 128 256)

    # Output path
    local src_dir src_base stem output
    src_dir="$(dirname "$source")"
    src_base="$(basename "$source")"
    stem="${src_base%.*}"
    output="${2:-"$src_dir/$stem.ico"}"

    # Check tools
    command -v inkscape >/dev/null 2>&1 || { echo "Inkscape not found in PATH" >&2; exit 1; }
    local magick_cmd="magick"
    if ! command -v magick >/dev/null 2>&1; then
        if command -v convert >/dev/null 2>&1; then
            magick_cmd="convert" # ImageMagick 6 fallback
        else
            echo "ImageMagick not found (need 'magick' or 'convert')" >&2
            exit 1
        fi
    fi

    # Temp dir for intermediates
    local tmpdir
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT

    # Export PNGs
    local -a pngs=()
    for size in "${sizes[@]}"; do
        local png="$tmpdir/${stem}-${size}.png"
        inkscape "$source" \
            --export-type=png \
            --export-filename="$png" \
            --export-width="$size" \
            --export-height="$size"
        pngs+=("$png")
    done

    # Build ICO (order from smallest to largest is conventional)
    if [[ "$magick_cmd" == "magick" ]]; then
        magick "${pngs[@]}" "$output"
    else
        convert "${pngs[@]}" "$output"
    fi

    echo "Wrote $output"
}

main "$@"
