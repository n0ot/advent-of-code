#!/usr/bin/env bash

mapfile lines
read -ra ops <<<"${lines[-1]}"
op_i=$((${#ops[@]} - 1))

total=0
tokens=()
in_problem=no
for ((col = ${#lines[0]} - 1; col >= 0; col--)); do
    digits=
    for ((i = 0; i < ${#lines[@]} - 1; i++)); do
        c="${lines[i]:$col:1}"
        [[ $c =~ [0-9] ]] && digits+="$c"
    done

    if [[ -n $digits ]]; then
        tokens+=("$digits")
        in_problem=yes
        continue
    fi

    # Skip over multiple empty columns
    [[ $in_problem = no ]] && continue
    in_problem=no

    answer="${tokens[0]}"
    for ((j = 1; j < ${#tokens[@]}; j++)); do
        case "${ops[op_i]}" in
        \+) ((answer += tokens[j])) ;;
        \*) ((answer *= tokens[j])) ;;
        *)
            echo >&2 "Invalid operator: $op"
            exit 2
            ;;
        esac
    done
    ((total += answer))
    tokens=()
    if ((--op_i < 0)); then
        echo >&2 "found more problems than operators on column $col"
        exit 2
    fi
done

if ((op_i > 0)); then
    echo >&2 "Found more operators than problems"
    exit 2
fi

answer="$(printf %s\\n "${tokens[@]}" | paste -sd "${ops[op_i]}" - | bc -l)"
((total += answer))

echo "$total"
