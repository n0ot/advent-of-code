#!/usr/bin/env bash

get_to_remove() {
    local -n _to_remove_ref="$1"
    _to_remove_ref=()
    local row col
    for roll in "${!rolls[@]}"; do
        local count=0
        IFS=. read -r row col <<<"$roll"
        for check_roll in {$((row - 1)),$row,$((row + 1))}.{$((col - 1)),$col,$((col + 1))}; do
            [[ $check_roll = "$row.$col" ]] && continue # Don't check your own roll
            [[ -n ${rolls[$check_roll]} ]] && ((count++))
        done
        [[ $count -lt 4 ]] && _to_remove_ref+=("$roll")
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
