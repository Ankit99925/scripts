#!/bin/bash

set -euo pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
check(){
    local host="$1" port="$2"
    if nc -z -w2 "$host" "$port" 2>/dev/null; then
        echo "UP $host:$port"
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
        if ! check "$host" "$port"; then
            failed=1
        fi
    done < "$script_dir/hosts.txt.example"
    return "$failed"
}

main "$@"
