#!/usr/bin/env bash

read_ranges() {
    local -n _ranges_ref="$1"
    local line ranges_all=()
    while read -r line; do
        [[ -z $line ]] && break # Blank line means no more ranges
        ranges_all+=("$line")
    done
    mapfile -t ranges_all <<<"$(printf %s\\n "${ranges_all[@]}" | sort -n)"

    local range start end prev_end=0 i=0
    for range in "${ranges_all[@]}"; do
        IFS=- read -r start end <<<"$range"
        ((end <= prev_end)) && continue # This range is encompassed
        if ((i > 0 && start <= prev_end)); then
            # Extend previous range to the right
            _ranges_ref[i - 1]="${_ranges_ref[i - 1]%-*}-$end"
        else
            # No overlap; add a new range
            _ranges_ref+=("$range")
            ((i++))
        fi
        prev_end="$end"
    done
}
