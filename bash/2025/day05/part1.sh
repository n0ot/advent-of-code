#!/usr/bin/env bash

. helper.sh
ranges=()
read_ranges ranges

ids=()
while read -r id; do ids+=("$id"); done
mapfile -t ids <<<"$(printf %s\\n "${ids[@]}" | sort -n)"

total=0
# Sum the count of IDs valid for each range
i=0
for range in "${ranges[@]}"; do
    IFS=- read -r start end <<<"$range"
    # Find the first valid ID in this range
    for (( ; i < ${#ids[@]} && ids[i] < start; i++)); do :; done
    ((i >= ${#ids[@]})) && break # No more valid IDs
    first_valid="$i"
    # Find the first invalid ID for this range (or the end of the IDs)
    for (( ; i < ${#ids[@]} && ids[i] <= end; i++)); do :; done
    ((total += i - first_valid))
done
echo "$total"
