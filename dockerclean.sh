#!/bin/bash

set -euo pipefail

usage(){
    cat >&2 <<EOF
Usage: $(basename "$0")

Lists exited containers and dangling images, then removes them
after confirmation. Containers named in the PROTECTED array at
the top of this script are always skipped.

EOF
    exit 1
}
# Containers that must never be removed, by name.
# Add any container you want to keep even when it is stopped —
# databases, monitoring, anything you will start again later.
PROTECTED=(nursery-db marketplace-api prometheus grafana node-exporter)
report() {
    local label="$1"
    shift
    local -a items=("$@")
    if (( ${#items[@]} > 0 )); then
        echo "$label: ${items[*]}"
    else
        echo "$label: none"
    fi
}

main(){
    local -a rows to_remove=() images

    mapfile -t rows < <(docker ps -a -f status=exited --format '{{.ID}} {{.Names}}')
    mapfile -t images < <(docker images -f dangling=true -q)

    for row in "${rows[@]}"; do
        local name
        read -r _ name <<< "$row"
        if [[ " ${PROTECTED[*]} " == *" $name "* ]]; then
            echo "Skipping protected: $name"
            continue
        fi
        to_remove+=("$name")
    done

    report "Exited containers" "${to_remove[@]}"
    report "Dangling images" "${images[@]}"

    if (( ${#to_remove[@]} > 0 )); then
        read -rp "Remove ${#to_remove[@]} container(s): ${to_remove[*]} ? [y/N] " answer
        if [[ "$answer" == [yY] ]]; then
            docker rm "${to_remove[@]}"
        else
            echo "Aborted"
        fi
    fi
}
main "$@"
