#!/usr/bin/env bash

set -e

search_line() {
    local prev_line="$1"
    local this_line="$2"
    local next_line="$3"

    local sum=0
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

        [[ $count -lt 4 ]] && ((sum++))
    done
    echo "$sum"
}

# Look at 3 lines at a time
prev_line=
if ! read -r this_line; then
    # No lines, no rolls of paper.
    echo 0
fi
sum=0
while read -r next_line; do
    this_sum="$(search_line "$prev_line" "$this_line" "$next_line")"
    ((sum += this_sum))
    prev_line="$this_line"
    this_line="$next_line"
done
next_line=
this_sum="$(search_line "$prev_line" "$this_line" "$next_line")"
((sum += this_sum))
echo "$sum"
