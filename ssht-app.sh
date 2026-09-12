#!/bin/bash

set -euo pipefail

usage(){
    cat >&2 <<EOF
Usage: $(basename "$0") [PATTERN]

Connects to a host from ~/.ssh/config by partial name match.

  $(basename "$0")            list all configured hosts
  $(basename "$0") app        connect if exactly one host matches
  $(basename "$0") -h         show this help

Exits 1 if no host matches, or if the pattern is ambiguous.
EOF
    exit 1
}
allhost=$(grep -i '^Host ' ~/.ssh/config | awk '{print $2}')

while getopts "h" opt; do
    case "$opt" in
        h) usage ;;
        \?) usage ;;
    esac
done

shift $((OPTIND - 1))

main(){
    if [[ $# -eq 0 ]]; then
        echo "All hosts:"
        echo "$allhost"
        exit 0
    fi

    local -a matches=()
    while read -r line; do
        [[ "$line" == *"$1"* ]] && matches+=("$line")
    done <<< "$allhost"

    local count=${#matches[@]}

    if (( count == 1 )); then
        exec ssh "${matches[0]}"
    elif (( count > 1 )); then
        echo "Multiple matches for $1:" >&2
        printf '  %s\n' "${matches[@]}"
        exit 1
    else
        echo "No host matching $1" >&2
        exit 1
    fi
}

main "$@"
