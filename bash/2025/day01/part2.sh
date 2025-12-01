#!/usr/bin/env bash

lock=50
password=0
while read -r line; do
    rotations="${line:1}" # Strips the L/R
    [[ $line = L* ]] && ((rotations*=-1))
    # If lock > 0, and we're rotating left, the initial zero crossing isn't handled by integer division.
    # For example lock= 50, L68 -> lock = -18 (82 after modulo).
    # -18/100 = 0, but there was 1 crossing over zero.
    [[ $lock -gt 0 && $rotations -lt 0 ]] && ((rotations-=100))
    zeros=$(((lock+rotations) / 100))
    zeros="${zeros#-}"
    ((password += zeros))
    # Lock must always be an integer between 0 and 99,
    # but in Bash, x % y, where x < 0 is negative.
    # The 100 + ... % 100 handles that.
    lock=$(((100 + lock+rotations % 100) % 100))
done

echo "$password"
