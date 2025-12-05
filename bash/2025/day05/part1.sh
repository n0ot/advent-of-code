#!/usr/bin/env bash

. helper.sh
declare -A ranges
read_ranges ranges

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
