#!/usr/bin/env bash

. helper.sh
read_rolls
get_to_remove to_remove
echo "${#to_remove[@]}"
