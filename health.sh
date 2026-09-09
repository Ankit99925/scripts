#!/bin/bash
set -euo pipefail

main() {
local failed=0

if (( $# > 0 )); then
    for h in "$@"; do
        echo "### $h ###"
        if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$h" 'bash -s' < "$0"; then
            echo "UNREACHABLE: $h"
            failed=1
        fi
    done

    return "$failed"
fi

echo "=== $(hostname) ==="
echo
echo "--- Uptime ---"
uptime

echo
echo "--- Disk ---"
df -h /

echo
echo "--- Memory ---"
free -h

if command -v docker >/dev/null 2>&1; then
    echo
    echo "--- Containers ---"
    docker ps --format 'table {{.Names}}\t{{.Status}}'
fi

disk_pct=$(df --output=pcent / | tail -1 | tr -d ' %')
if ((disk_pct > 80)); then
    echo "Warning! disk at ${disk_pct}%"
    exit 1
fi
}

main "$@"
