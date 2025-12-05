#!/usr/bin/env bash

. helper.sh
declare ranges
read_ranges ranges

total=0
for range in "${ranges[@]}"; do
    IFS=- read -r start end <<<"$range"
    ((total += end + 1 - start))
done
echo "$total"
