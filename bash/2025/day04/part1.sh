#!/usr/bin/env bash

. helper.sh
read_rolls
declare -A removeable
get_removeable removeable
echo "${#removeable[@]}"
