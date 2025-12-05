#!/usr/bin/env bash

while IFS=- read -r start end; do
    [[ -z $end ]] && continue
    if [[ $start -gt $highest_end ]]; then
        # No overlap
        ((total += end + 1 - start))
        highest_end="$end"
        continue
    fi
    [[ $end -lt $highest_end ]] && continue # This range is fully encompassed
    ((total += end - highest_end))
    highest_end="$end" # Expand previous range to the right
done < <(sed '/^$/q' | sort -n)
echo "$total"
