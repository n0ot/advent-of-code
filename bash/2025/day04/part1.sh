#!/usr/bin/env bash

. helper.sh
declare -A rolls
declare -A removeable
read_rolls rolls removeable
echo "${#removeable[@]}"
