#!/usr/bin/env bash

read_ranges() {
    local -n _ranges_ref="$1"
    local range this_start this_end existing_range existing_start existing_end
    while read -r range; do
        [[ -z $range ]] && break
        # Expand existing ranges if this one overlaps
        IFS=- read -r this_start this_end <<<"$range"
        for existing_range in "${!_ranges_ref[@]}"; do
            IFS=- read -r existing_start existing_end <<<"$existing_range"
            if [[ $existing_start -le $this_start && $this_end -le $existing_end ]]; then
                continue 2 # This range is fully encompassed by another
            fi
            if [[ $this_start -le $existing_start && $existing_start -le $this_end ]]; then
                # the existing range overlaps this one on the right
                # Expand this range to the right, unless existing range is fully encompassed.
                [[ $existing_end -gt $this_end ]] && this_end="$existing_end"
                unset '_ranges_ref['"$existing_range"']'
            elif [[ $this_start -le $existing_end && $existing_end -le $this_end ]]; then
                # the existing range overlaps this one on the left
                # Expand this range to the left.
                # The case of this range being fully encompassed is already handled.
                this_start="$existing_start"
                unset '_ranges_ref['"$existing_range"']'
            fi
        done
        _ranges_ref["$this_start-$this_end"]=
    done
}
