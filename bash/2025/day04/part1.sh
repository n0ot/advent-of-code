#!/usr/bin/env bash

. helper.sh
read_rolls
IFS=' ' read -ra to_remove <<<"$(can_remove)"
echo "${#to_remove[@]}"
