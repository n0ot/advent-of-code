#!/usr/bin/env bash

beams=()
total_splits=0
while read -r line; do
    for ((i = 0; i < ${#line}; i++)); do
        case "${line:i:1}" in
        S) beams[i]=1 ;;
        ^)
            [[ -z ${beams[i]} ]] && continue # No beam here to split
            beams[i]=
            ((i > 0)) && beams[i - 1]=1
            ((i < ${#line} - 1)) && beams[i + 1]=1
            ((total_splits++))
            ;;
        esac
    done
done

echo "$total_splits"
