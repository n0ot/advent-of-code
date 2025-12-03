#!/usr/bin/env bash

set -e

# Inspired very heavily by https://github.com/cgsdev0/advent-of-code/tree/main/2025/day02/p2-2-golfed.sh

seq_cmd=seq
hash gseq &> /dev/null & seq_cmd=gseq

tr ,- ' ' |
    xargs -n2 "$seq_cmd" |
    grep -E '^(.+)\1$' |
    paste -sd+ - |
    bc
