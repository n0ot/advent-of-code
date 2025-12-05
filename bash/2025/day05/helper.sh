#!/usr/bin/env bash

read_ranges() {
    local -n _ranges_ref="$1"
    local range this_start this_end existing_range existing_start existing_end add_this_range
    while read -r range; do
        [[ -z $range ]] && break
        # Expand existing ranges if this one overlaps
        IFS=- read -r this_start this_end <<<"$range"
        add_this_range=yes
        for existing_range in "${!_ranges_ref[@]}"; do
            IFS=- read -r existing_start existing_end <<<"$existing_range"
            if [[ $this_start -le $existing_start && $existing_start -le $this_end ]]; then
                [[ $existing_end -gt $this_end ]] && this_end="$existing_end"
                unset '_ranges_ref['"$existing_range"']'
            elif [[ $this_start -le $existing_end && $existing_end -le $this_end ]]; then
                [[ $existing_start -lt $this_start ]] && this_start="$existing_start"
                unset '_ranges_ref['"$existing_range"']'
            elif [[ $existing_start -le $this_start && $this_end -le $existing_end ]]; then
                add_this_range=no
            fi
        done
        [[ $add_this_range = yes ]] && _ranges_ref["$this_start-$this_end"]=
    done
}
