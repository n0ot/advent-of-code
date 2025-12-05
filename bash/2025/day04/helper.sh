#!/usr/bin/env bash

get_to_remove() {
    to_remove=()
    local row col
    for roll in "${!rolls[@]}"; do
        local count=0
        IFS=. read -r row col <<<"$roll"
        for check_roll in {$((row - 1)),$row,$((row + 1))}.{$((col - 1)),$col,$((col + 1))}; do
            [[ $check_roll = "$row.$col" ]] && continue # Don't check your own roll
            [[ -n ${rolls[$check_roll]} ]] && ((count++))
        done
        [[ $count -lt 4 ]] && to_remove+=("$roll")
    done
}

declare -A rolls
read_rolls() {
    local c
    local i=0 j=0
    while IFS= read -rn1 c; do
        case "$c" in
        '') # newline
            ((i++))
            j=-1 # will be set to 0 when incremented
            ;;
        @) rolls["$i.$j"]=@ ;;
        *) ;;
        esac
        ((j++))
    done
}
