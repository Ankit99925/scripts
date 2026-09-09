#!/bin/bash

set -euo pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
check(){
    local host="$1" port="$2"
    if nc -z -w2 "$host" "$port" 2>/dev/null; then
        echo "UP $host:$port"
    else
        echo "DOWN $host:$port"
    fi
}

main(){
    while read -r host port; do
        check "$host" "$port"
    done < "$script_dir/hosts.txt"
}

main "$@"
