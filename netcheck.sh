#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

usage(){
    echo "Usage: $(basename "$0") [-f FILE] [-t SECONDS] [-q]" >&2
    exit 1
}

host_file="$script_dir/hosts.txt"
timeout=2
quiet=0

while getopts ":f:t:qh" opt; do
    case "$opt" in
        f) host_file="$OPTARG";;
        t) timeout="$OPTARG";;
        q) quiet=1;;
        h) usage ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage ;;
        :)  echo "Option -$OPTARG needs a value" >&2; usage ;;
    esac
done
shift $((OPTIND -1))

check(){
    local host="$1" port="$2"
    if nc -z -w"$timeout" "$host" "$port" 2>/dev/null; then
        ((quiet)) || echo "UP $host:$port"
    else
        echo "DOWN $host:$port"
        return 1
    fi
}

main(){
    local failed=0
    while read -r host port; do
        [[ -z "$host" ]] && continue
        [[ "$host" == \#* ]] && continue
        if [[ -z "$port" ]]; then
            echo "SKIP  $host (no port specified)" >&2
            continue
        fi
        if ! check "$host" "$port"; then
            failed=1
        fi
    done < "$host_file"
    return "$failed"
}

main "$@"
