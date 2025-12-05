#!/usr/bin/env bash

. helper.sh
declare -A rolls
declare -A removeable
read_rolls rolls removeable

total=0
while [[ ${#removeable[@]} -ne 0 ]]; do
    ((total += ${#removeable[@]}))
    for roll in "${!removeable[@]}"; do
        unset 'rolls['"$roll"']'
        IFS=. read -r row col <<<"$roll"
        for check_roll in {$((row - 1)),"$row",$((row + 1))}.{$((col - 1)),"$col",$((col + 1))}; do
            [[ $check_roll = "$roll" ]] && continue # Don't check your own roll
            [[ -z ${rolls["$check_roll"]} ]] && continue
            ((rolls["$check_roll"]--))
            [[ ${rolls["$check_roll"]} -lt 4 ]] && removeable["$check_roll"]=@
        done
        unset 'removeable['"$roll"']'
    done
done

echo "$total"
