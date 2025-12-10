#!/usr/bin/env bash

limit=1000
# Read in points in the form x,y,z; one per line
mapfile -t points
[[ ${#points[@]} -lt 100 ]] && limit=10

# Build pair of points to all other points.
# There will be (n^2-n)/2 pairs, where n is the number of points.
declare -A pairs_map # A set, with format "distance point1 idx point2_idx"
for i in "${!points[@]}"; do
    IFS=, read -r x1 y1 z1 <<<"${points[i]}"
    for ((j = i + 1; j < ${#points[@]}; j++)); do
        IFS=, read -r x2 y2 z2 <<<"${points[j]}"
        # Normally, the distance formula requires sqrt, but bash can't do that, and bc is too slow.
        # That's fine; we don't really need the true distance, just correct sorting.
        distance=$(((x2 > x1 ? x2 - x1 : x1 - x2) ** 2 + (y2 > y1 ? y2 - y1 : y1 - y2) ** 2 + (z2 > z1 ? z2 - z1 : z1 - z2) ** 2))
        pairs_map["$distance $i $j"]=1
    done
done
# Sort pairs by smallist distance, and take the first $limit.
mapfile -t pairs < <(printf %s\\n "${!pairs_map[@]}" | sort -n | head -n "$limit")

circuits=()
points_circuit=()

# Build circuits
for pair in "${pairs[@]}"; do
    read -r _ point1 point2 <<<"$pair"
    point1_circuit="${points_circuit[point1]:-"-1"}"
    point2_circuit="${points_circuit[point2]:-"-1"}"

    if [[ $point1_circuit -eq -1 && $point2_circuit -eq -1 ]]; then
        # Neither point is in a circuit; create a new one.
        circuits+=(" $point1 $point2 ")
        indexes=("${!circuits[@]}")
        points_circuit[point1]="${indexes[-1]}"
        points_circuit[point2]="${indexes[-1]}"
        continue
    fi
    if [[ $point1_circuit == "$point2_circuit" ]]; then
        continue # Both points are already in the same circuit; nothing to do
    fi
    if [[ $point1_circuit -eq -1 ]]; then
        circuits[point2_circuit]+=" $point1 "
        points_circuit[point1]="$point2_circuit"
        continue
    fi
    if [[ $point2_circuit -eq -1 ]]; then
        circuits[point1_circuit]+=" $point2 "
        points_circuit[point2]="$point1_circuit"
        continue
    fi
    # Both points are in different circuits; merge them.
    circuits[point1_circuit]="${circuits[point1_circuit]}${circuits[point2_circuit]}"
    read -ra points_to_move <<<"${circuits[point2_circuit]}"
    for point in "${points_to_move[@]}"; do points_circuit[point]="$point1_circuit"; done
    unset 'circuits[point2_circuit]'
done

circuit_counts=()
for circuit in "${circuits[@]}"; do
    read -ra circuit_arr <<<"$circuit"
    circuit_counts+=("${#circuit_arr[@]}")
done

printf %s\\n "${circuit_counts[@]}" | sort -rn | head -n 3 | paste -sd'*' - | bc -l
