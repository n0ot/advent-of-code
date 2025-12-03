#!/usr/bin/env bash

set -e

is_valid() {
    local id="$1"
    local id_len="${#id}"
    for ((divs = 2; divs <= id_len; divs++)); do
        [[ $((id_len % divs)) -eq 0 ]] || continue
        chunk_size=$((id_len / divs))
        first="${id::chunk_size}"
        for ((i = 1; i < divs; i++)); do
            chunk="${id:$((i * chunk_size)):chunk_size}"
            [[ $chunk != "$first" ]] && continue 2
        done
        return 1
    done
}

sum=0
read -r line
IFS=, read -ra ranges <<<"$line"
for range in "${ranges[@]}"; do
    IFS=- read -r low high <<<"$range"
    for ((id = low; id <= high; id++)); do
        is_valid $id || ((sum += id))
    done
done

echo "$sum"
