#!/usr/bin/env bash

calculate_piece_size() {
    local size_mib=$1
    local size_bytes=$((size_mib * 1024 * 1024))
    local piece_size=$((16 * 1024))
    local max_piece_size=$((16 * 1024 * 1024))
    local actual_calculated_piece_size

    while ((size_bytes / piece_size > 1000)); do
        piece_size=$((piece_size * 2))
    done

    actual_calculated_piece_size=$piece_size

    if ((piece_size > max_piece_size)); then
        piece_size=$max_piece_size
    fi

    actual_hr=$(convert_to_human_readable $actual_calculated_piece_size)
    recommended_hr=$(convert_to_human_readable $piece_size)

    echo "Piece size: $actual_hr"

    if ((actual_calculated_piece_size > max_piece_size)); then
        echo "Recommended piece size: $recommended_hr (For compatibility with old clients)"
    fi
}

convert_to_human_readable() {
    local size_bytes=$1
    if ((size_bytes >= 1024 * 1024)); then
        echo "$((size_bytes / 1024 / 1024)) MiB"
    elif ((size_bytes >= 1024)); then
        echo "$((size_bytes / 1024)) KiB"
    else
        echo "$size_bytes bytes"
    fi
}

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <size> <unit>"
    echo "  <size>: Numeric value of the torrent size (e.g., 3.907)"
    echo "  <unit>: Unit of the size (g/G (GiB) or m/M (MiB))"
    exit 1
fi

size=$1
unit=$2

if ! [[ "$size" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Invalid size. Provide a numeric value."
    exit 1
fi

if [[ "${unit,,}" == "gib" || "${unit,,}" == "g" ]]; then
    size_mib=$(awk "BEGIN {printf \"%d\", $size * 1024}")
elif [[ "${unit,,}" == "mib" || "${unit,,}" == "m" ]]; then
    size_mib=$(awk "BEGIN {printf \"%d\", $size}")
else
    echo "Invalid unit. Use 'g/G', 'GiB' or 'm/M', 'MiB'."
    exit 1
fi

calculate_piece_size $size_mib
