#!/usr/bin/env bash

. helper.sh
read_rolls

total=0
while :; do
    IFS=' ' read -ra to_remove <<<"$(can_remove)"
    [[ ${#to_remove[@]} -eq 0 ]] && break
    for roll in "${to_remove[@]}"; do
        unset 'rolls['"$roll"']'
    done
    ((total += ${#to_remove[@]}))
done

echo "$total"
