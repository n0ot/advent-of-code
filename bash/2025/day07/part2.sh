#!/usr/bin/env bash

beams=()
total_timelines=1
while read -r line; do
    for ((i = 0; i < ${#line}; i++)); do
        case "${line:i:1}" in
        S)
            beams[i]=1 ;;
        ^)
            [[ -z ${beams[i]} ]] && continue # No beam here to split
            ((i > 0)) && ((beams[i - 1]+=beams[i]))
            ((i < ${#line} - 1)) && ((beams[i + 1]+=beams[i]))
            ((total_timelines+=beams[i]))
            beams[i]=
            ;;
        esac
    done
done

echo "$total_timelines"
