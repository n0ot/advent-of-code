#!/usr/bin/env bash

declare -A problems
j=0
while read -ra line; do
    for i in "${!line[@]}"; do problems["$i.$j"]="${line[i]}"; done
    num_cols="${#line[@]}"
    ((j++))
done
num_lines="$j"

total=0
for ((i = 0; i < num_cols; i++)); do
    mapfile -t tokens < <(for ((j = 0; j < num_lines - 1; j++)); do printf %s\\n "${problems["$i.$j"]}"; done)
    op="${problems["$i.$((num_lines - 1))"]}"
    answer="${tokens[0]}"
    for ((j = 1; j < ${#tokens[@]}; j++)); do
        case "$op" in
        \+) ((answer += tokens[j])) ;;
        \*) ((answer *= tokens[j])) ;;
        *)
            echo >&2 "Invalid operator: $op"
            exit 2
            ;;
        esac
    done
    ((total += answer))
done

echo "$total"
