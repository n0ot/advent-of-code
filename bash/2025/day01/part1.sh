#!/usr/bin/env bash

lock=50
password=0
while read -r line; do
    rotations="${line:1}"
    case "$line" in
    L*) ((lock -= rotations)) ;;
    R*) ((lock += rotations)) ;;
    esac
    lock=$(((100 + lock % 100) % 100))
    [[ $lock -eq 0 ]] && ((password++))
done

echo "$password"
