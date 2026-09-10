# scripts

Small ops tools for checking and managing my servers.

## health

Reports uptime, disk, memory and running containers. Runs locally, or over
SSH against one or more hosts.

    ./health.sh                      # this machine
    ./health.sh host1 host2          # remote, via ssh

Exits non-zero if any host is unreachable or disk usage exceeds 80%.
Requires key-based SSH auth (BatchMode is on, so it will not prompt).

## netcheck

Checks host:port reachability from a list.

    cp hosts.txt.example hosts.txt   # then edit
    ./netcheck.sh

Exits non-zero if anything is down.

## gcp-start-stop

Starts or stops a GCE instance. Idempotent — safe to run repeatedly.

    INSTANCE=my-vm ZONE=us-west1-b ./gcp-start-stop.sh status
    INSTANCE=my-vm ZONE=us-west1-b ./gcp-start-stop.sh stop

Requires an authenticated `gcloud`.

## systemd

Unit files for running `health` on a schedule. Copy to
`~/.config/systemd/user/`, then:

    systemctl --user enable --now health.timer
