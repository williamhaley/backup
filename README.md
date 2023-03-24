# Backup

Semi-complicated bash scripts used for backing up a system.

# Install

```
make
make install
```

# Config

Config files should be located at `/etc/backup/...` and named with a `yaml` extension.

```
# enabled: false

filters: |-
  - node_modules
  - .Trash*

  + /mnt
  + /mnt/storage
  + /mnt/storage/archives**
  - /**

destination: /mnt/backup/backup-archives

b2:
  enabled: true
  application_key_id: abcd1234
  application_key: abcd1234
  bucket: my-bucket
  - '.*/my-directory/with-subdirectory/.*'

destinations:
  - path: /mnt/backup-drive-1
  - path: /mnt/backup-drive-2
```

# Prior Art

* https://wiki.archlinux.org/title/rsync#Snapshot_backup
