#!/usr/bin/env bash

flock \
    --exclusive \
    --nonblock \
    --conflict-exit-code 100 \
    /tmp/backup.lockfile \
    /usr/local/bin/backup --verbose | logger -t backup
