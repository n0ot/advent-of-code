#!/usr/bin/env bash

lock=50
password=0
while read -r line; do
    rotations="${line:1}"
    case "$line" in
    L*)
        ((lock -= rotations))
        [[ $lock -ne -$rotations ]] && ((lock -= 100))
        ;;
    R*) ((lock += rotations)) ;;
    esac
    zeros=$((lock / 100))
    zeros="${zeros#-}"
    ((password += zeros))
    lock=$(((100 + lock % 100) % 100))
    #echo "$line $lock $password"
done

echo "$password"
