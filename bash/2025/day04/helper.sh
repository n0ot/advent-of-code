#!/usr/bin/env bash

is_removeable() {
    local row col check_roll roll="$1" count=0
    IFS=. read -r row col <<<"$roll"
    for check_roll in {$((row - 1)),"$row",$((row + 1))}.{$((col - 1)),"$col",$((col + 1))}; do
        [[ $check_roll = "$roll" ]] && continue # Don't check your own roll
        [[ -n ${rolls[$check_roll]} ]] && ((count++))
    done
    [[ $count -lt 4 ]] && return 0 || return 1
}

get_removeable() {
    local -n _removeable_ref="$1"
    #declare -A _removeable_ref
    for roll in "${!rolls[@]}"; do
        is_removeable "$roll" && _removeable_ref["$roll"]=@
    done
}

declare -A rolls
read_rolls() {
    local line i=0 j
    while IFS= read -r line; do
        for ((j = 0; j < ${#line}; j++)); do
            [[ ${line:$j:1} = @ ]] && rolls["$i.$j"]=@
        done
        ((i++))
    done
}
