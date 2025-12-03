#!/usr/bin/env bash

set -e

if [[ $# -lt 1 ]]; then
    echo >&2 "Usage: $0 <num-jolt-digits>"
    exit 1
fi
num_jolt_digits="$1"

sum=0
while read -r line; do
    digits=
    max_idx=-1
    for ((i = 0; i < num_jolt_digits; i++)); do
        end=$((${#line} - num_jolt_digits+i))
        max_digit=0
        for ((j = max_idx+1; j <= end; j++)); do
            digit="${line:j:1}"
            if [[ $digit -gt $max_digit ]]; then
                max_idx=$j
                max_digit="$digit"
            fi
            [[ $digit -eq 9 ]] && break
        done
        digits="${digits}$max_digit"
    done
    ((sum+=digits))
done
echo "$sum"
