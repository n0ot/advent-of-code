#!/usr/bin/env bash

lock=50
password=0
while read -r line; do
    rotations="${line:1}" # Strips the L/R
    [[ $line = L* ]] && ((rotations*=-1))
    # Lock must always be an integer between 0 and 99,
    # but in Bash, x % y, where x < 0 is negative.
    # The 100 + ... % 100 handles that.
    lock=$(((100 + lock+rotations % 100) % 100))
    [[ $lock -eq 0 ]] && ((password++))
done

echo "$password"
