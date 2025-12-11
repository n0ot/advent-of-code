#!/usr/bin/env bash

# Read in points in the form x,y; one per line
mapfile -t points

# Build pair of points to all other points,
# and enumerate ranges.
# There will be (n^2-n)/2 pairs, where n is the number of points.
declare -A pairs_map # A set, with format "area point1 idx point2_idx"
vranges=()           # x -> "y1_start-y1_end y2_start-y2_end..."
hranges=()           # y -> "x1_start-x1_end x2_start-x2_end..."
prev_point="${points[-1]}"
max_x=0
for i in "${!points[@]}"; do
    IFS=, read -r x1 y1 <<<"${points[i]}"
    ((x1 > max_x)) && max_x="$x1"
    IFS=, read -r prev_x prev_y <<<"$prev_point"
    prev_point="${points[i]}"
    if [[ $x1 -eq $prev_x ]]; then
        range_start=$((y1 < prev_y ? y1 : prev_y))
        range_end=$((y1 > prev_y ? y1 : prev_y))
        vranges[x1]+="$range_start-$range_end "
    elif [[ $y1 -eq $prev_y ]]; then
        range_start=$((x1 < prev_x ? x1 : prev_x))
        range_end=$((x1 > prev_x ? x1 : prev_x))
        hranges[y1]+="$range_start-$range_end "
    else
        echo >&2 "The puzzle promised every subsequent tile would be on the same line, but it lied."
        exit 1
    fi

    for ((j = i + 1; j < ${#points[@]}; j++)); do
        IFS=, read -r x2 y2 <<<"${points[j]}"
        area=$(((x2 > x1 ? x2 - x1 + 1 : x1 - x2 + 1) * (y2 > y1 ? y2 - y1 + 1 : y1 - y2 + 1)))
        pairs_map["$area $i $j"]=1
    done
done

# Sort pairs by largest area.
mapfile -t pairs < <(printf %s\\n "${!pairs_map[@]}" | sort -rn)

find_first() {
    local -n _haystack_ref="$2"
    local needle="$1" low=0 high="${#_haystack_ref[@]}" mid
    while ((low != high)); do
        mid=$(((low + high) / 2))
        if [[ ${_haystack_ref[mid]} -lt $needle ]]; then
            low=$((mid + 1))
        else
            high="$mid"
        fi
    done
    ((low >= ${#_haystack_ref[@]})) && return
    echo "$low"
}

vrange_indexes=("${!vranges[@]}")
hrange_indexes=("${!hranges[@]}")

for pair in "${pairs[@]}"; do
    read -r area point1_i point2_i <<<"${pair[@]}"
    IFS=, read -r x1 y1 <<<"${points[point1_i]}"
    IFS=, read -r x2 y2 <<<"${points[point2_i]}"
    # top left coordinate is (0, 0)
    top=$((y1 < y2 ? y1 : y2))
    left=$((x1 < x2 ? x1 : x2))
    bottom=$((y1 > y2 ? y1 : y2))
    right=$((x1 > x2 ? x1 : x2))

    # If any lines intersect the rectangle anywhere but its edges, it's invalid.
    # This does not account for a 180 degree turn, which would leave no white tiles.
    i="$(find_first $((left + 1)) vrange_indexes)"
    if [[ -n "$i" ]]; then
        while ((i < ${#vrange_indexes[@]} && vrange_indexes[i] < right)); do
            read -ra ranges <<<"${vranges[${vrange_indexes[i]}]}"
            for range in "${ranges[@]}"; do
                IFS=- read -r start end <<<"$range"
                ((end > top && start < bottom)) && continue 3 # Vertical line intersects
            done
            ((i++))
        done
    fi
    i="$(find_first $((top + 1)) hrange_indexes)"
    if [[ -n "$i" ]]; then
        while ((i < ${#hrange_indexes[@]} && hrange_indexes[i] < bottom)); do
            read -ra ranges <<<"${hranges[${hrange_indexes[i]}]}"
            for range in "${ranges[@]}"; do
                IFS=- read -r start end <<<"$range"
                ((end > left && start < right)) && continue 3 # Horizontal line intersects
            done
            ((i++))
        done
    fi

    # We found a rectangle with no intersecting lines,
    # now we need to check if the whole thing is inside the loop
    # We'll move right from the top right corner of the rectangle, and count the vertical line crossings.
    # If we find any horizontal lines here or to the right, we'll keep moving down till we don't.
    # That's not fool proof, but works for this puzzle.
    for ((i = top; i <= bottom; i++)); do
        read -ra ranges <<<"${hranges[i]}"
        for range in "${ranges[@]}"; do
            IFS=- read -r _ end <<<"$range"
            ((end >= right)) && continue 2 # found a horizontal line; have to move down
        done
        break # No horizontal lines here
    done
    echo "Checking rect=($left, $top) to ($right, $bottom), moving right on line $i"

    crossings=0
    j="$(find_first "$right" vrange_indexes)"
    if [[ -n "$j" ]]; then
        while ((j < ${#vrange_indexes[@]})); do
            read -ra ranges <<<"${vranges[${vrange_indexes[j]}]}"
            for range in "${ranges[@]}"; do
                IFS=- read -r start end <<<"$range"
                if ((start <= i && i <= end)); then
                    ((crossings++))
                    break
                fi
            done
            ((j++))
        done
    fi
    echo "Found $crossings crossings at $i"
    ((crossings % 2 == 0)) && continue # Even crossings means we're outside the loop

    echo "$area"
    exit
done
