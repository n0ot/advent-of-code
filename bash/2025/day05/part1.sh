#!/usr/bin/env bash

declare -A ranges
while read -r range; do
    [[ -z $range ]] && break
    # Expand existing ranges if this one overlaps
    IFS=- read -r this_start this_end <<<"$range"
    add_this_range=yes
    for existing_range in "${!ranges[@]}"; do
        IFS=- read -r existing_start existing_end <<<"$existing_range"
        if [[ $this_start -le $existing_start && $existing_start -le $this_end ]]; then
            [[ $existing_end -gt $this_end ]] && this_end="$existing_end"
            unset 'ranges['"$existing_range"']'
        elif [[ $this_start -le $existing_end && $existing_end -le $this_end ]]; then
            [[ $existing_start -lt $this_start ]] && this_start="$existing_start"
            unset 'ranges['"$existing_range"']'
        elif [[ $existing_start -le $this_start && $this_end -le $existing_end ]]; then
            add_this_range=no
        fi
    done
    [[ $add_this_range = yes ]] && ranges["$this_start-$this_end"]=
done

total=0
while read -r id; do
    for range in "${!ranges[@]}"; do
        IFS=- read -r start end <<<"$range"
        if [[ $start -le $id && $id -le $end ]]; then
            ((total++))
            continue 2
        fi
    done
done
echo "$total"
