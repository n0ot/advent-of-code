#!/usr/bin/env bash

ranges=()
while read -r range; do
    [[ -z $range ]] && break
    ranges+=("$range")
done

total=0
while read -r id; do
    for range in "${ranges[@]}"; do
        IFS=- read -r start end <<<"$range"
        if [[ $start -le $id && $id -le $end ]]; then
            ((total++))
            continue 2
        fi
    done
done
echo "$total"
