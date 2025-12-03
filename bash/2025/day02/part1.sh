#!/usr/bin/env bash

set -e

is_valid() {
    local id="$1"
    local id_len="${#id}"
    [[ $((id_len % 2)) -ne 0 ]] && return 0
    first="${id::$((id_len / 2))}"
    last="${id:$((id_len / 2))}"
    [[ $first != "$last" ]]
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
