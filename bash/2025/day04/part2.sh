#!/usr/bin/env bash

search_line() {
    local prev_line="$1"
    local this_line="$2"
    local next_line="$3"

    for ((i = 0; i < ${#this_line}; i++)); do
        [[ ${this_line:$i:1} != "@" ]] && continue
        local count=0
        if [[ -n $prev_line ]]; then
            [[ $i -gt 0 && ${prev_line:$((i - 1)):1} = "@" ]] && ((count++))
            [[ ${prev_line:$i:1} = "@" ]] && ((count++))
            [[ $i -lt $((${#this_line} - 1)) && ${prev_line:$((i + 1)):1} = "@" ]] && ((count++))
        fi
        [[ $i -gt 0 && ${this_line:$((i - 1)):1} = "@" ]] && ((count++))
        [[ $i -lt $((${#this_line} - 1)) && ${this_line:$((i + 1)):1} = "@" ]] && ((count++))
        if [[ -n $next_line ]]; then
            [[ $i -gt 0 && ${next_line:$((i - 1)):1} = "@" ]] && ((count++))
            [[ ${next_line:$i:1} = "@" ]] && ((count++))
            [[ $i -lt $((${#this_line} - 1)) && ${next_line:$((i + 1)):1} = "@" ]] && ((count++))
        fi

        [[ $count -lt 4 ]] && echo "$i"
    done
}

total=0
mapfile -t lines
while :; do
    to_rm=()
    for i in "${!lines[@]}"; do
        ((i > 0)) && prev_line="${lines[$((i - 1))]}" || prev_line=
        ((i <= ${#lines[@]} - 1)) && next_line="${lines[i + 1]}" || next_line=
        mapfile -t to_rm_this_line <<<"$(search_line "$prev_line" "${lines[i]}" "$next_line")"
        [[ ${#to_rm_this_line[@]} -eq 1 && -z ${to_rm_this_line[0]} ]] && continue # Nothing to remove
        for rm in "${to_rm_this_line[@]}"; do
            to_rm+=("$i" "$rm")
        done
    done

    [[ ${#to_rm[@]} -eq 0 ]] && break # Nothing more to do
    # Remove the rolls
    for ((i = 0; i < ${#to_rm[@]}; i += 2)); do
        line_num="${to_rm[i]}"
        rm="${to_rm[i + 1]}"
        sed_expr="$(printf 's/^(.{%d})./\\1./' "$rm")"
        lines[line_num]="$(printf %s "${lines[line_num]}" | sed -E "$sed_expr")"
        ((total++))
    done
done

echo "$total"
