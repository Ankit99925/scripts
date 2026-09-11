#!/bin/bash
set -euo pipefail

show_all=0

usage(){
    cat >&2 <<EOF
Usage: $(basename "$0") [-a] [-h]

Lists TCP ports this machine is listening on, with the owning process.

  -a   include loopback addresses (127.x)
  -h   show this help

Run with sudo to see process names for processes you don't own.
EOF
    exit 1
}

while getopts "ah" opt; do
    case "$opt" in
        a) show_all=1 ;;
        h) usage ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage ;;
    esac
done
shift $((OPTIND - 1))

if (( show_all )); then
    sudo ss -4 -tlnp | awk 'BEGIN { printf "%-16s %-8s %s\n", "ADDRESS", "PORT", "PROCESS" } NR>1 {
    split($4, a, ":")
    match($6, /"[^"]+"/)
    proc = substr($6, RSTART+1, RLENGTH-2)
    printf "%-16s %-8s %s\n", a[1], a[2], proc
}'
else
    sudo ss -4 -tlnp | awk 'BEGIN { printf "%-16s %-8s %s\n", "ADDRESS", "PORT", "PROCESS" } NR>1 && $4 !~ /^127\./ {
    split($4, a, ":")
    match($6, /"[^"]+"/)
    proc = substr($6, RSTART+1, RLENGTH-2)
    printf "%-16s %-8s %s\n", a[1], a[2], proc
}'
fi
