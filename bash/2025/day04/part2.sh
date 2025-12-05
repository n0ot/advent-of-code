#!/usr/bin/env bash

. helper.sh
read_rolls
declare -A removeable
get_removeable removeable

total=0
while [[ ${#removeable[@]} -ne 0 ]]; do
    ((total += ${#removeable[@]}))
    for roll in "${!removeable[@]}"; do
        unset 'rolls['"$roll"']'
        IFS=. read -r row col <<<"$roll"
        for check_roll in {$((row - 1)),"$row",$((row + 1))}.{$((col - 1)),"$col",$((col + 1))}; do
            [[ $check_roll = "$roll" ]] && continue # Don't check your own roll
            [[ ${rolls["$check_roll"]} != @ ]] && continue
            [[ -n ${removeable["$check_roll"]} ]] && continue
            is_removeable "$check_roll" && removeable["$check_roll"]=@
        done
        unset 'removeable['"$roll"']'
    done
done

echo "$total"
