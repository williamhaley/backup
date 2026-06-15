#!/usr/bin/env bash

set -e

timestamp="$(date +"%Y-%m-%dT%H.%M.%S")"

btrfs subvolume snapshot -r /mnt/backups/@backups /mnt/backups/snapshots/@backups."${timestamp}"
btrfs subvolume list -s /mnt/backups/@backups
