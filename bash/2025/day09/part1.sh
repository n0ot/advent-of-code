#!/usr/bin/env bash

# Read in points in the form x,y; one per line
mapfile -t points

for i in "${!points[@]}"; do
    IFS=, read -r x1 y1 <<<"${points[i]}"
    for ((j = i + 1; j < ${#points[@]}; j++)); do
        IFS=, read -r x2 y2 <<<"${points[j]}"
        echo $(((x2 > x1 ? x2 - x1 + 1 : x1 - x2 + 1) * (y2 > y1 ? y2 - y1 + 1 : y1 - y2 + 1)))
    done
done | sort -rn | head -n 1
