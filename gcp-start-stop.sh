#!/bin/bash

set -euo pipefail

INSTANCE="${INSTANCE:?set INSTANCE to the target instance name}"
ZONE="${ZONE:?set ZONE, e.g. us-west1-b}"

action=${1:-status}

status=$(gcloud compute instances describe "$INSTANCE" \
    --zone="$ZONE" --format='value(status)')

case $action in 

    status)
        echo "$INSTANCE is $status"
        ;;

    start) 
        if [[ $status == "RUNNING" ]]; then
            echo "ALREADY RUNNING"
            exit 0
        fi
        gcloud compute instances start "$INSTANCE" --zone="$ZONE"
        ;;

    stop)
        if [[ $status == "TERMINATED" ]]; then
            echo "ALREADY STOPPED"
            exit 0
        fi
        gcloud compute instances stop "$INSTANCE" --zone="$ZONE"
        ;;

    *)
        echo "Usage $0 {status|start|stop}" >&2
        exit 1
        ;;

esac
