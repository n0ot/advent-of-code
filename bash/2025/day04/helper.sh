#!/usr/bin/env bash

read_rolls() {
    local -n _rolls_ref="$1"
    local -n _removeable_ref="$2"
    local line i=0 j
    while IFS= read -r line; do
        for ((j = 0; j < ${#line}; j++)); do
            [[ ${line:$j:1} = @ ]] && _rolls_ref["$i.$j"]=0
        done
        ((i++))
    done

    for roll in "${!_rolls_ref[@]}"; do
        local row col check_roll count=0
        IFS=. read -r row col <<<"$roll"
        for check_roll in {$((row - 1)),"$row",$((row + 1))}.{$((col - 1)),"$col",$((col + 1))}; do
            [[ $check_roll = "$roll" ]] && continue # Don't check your own roll
            [[ -n ${rolls[$check_roll]} ]] && ((count++))
        done
        _rolls_ref["$roll"]="$count"
        [[ $count -lt 4 ]] && _removeable_ref["$roll"]=@
    done
}
