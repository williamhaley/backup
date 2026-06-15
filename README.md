# Backup

Semi-complicated scripts, applications, and other helpers used for backing up my systems. This is a personal project with no support, guarantees, or assurances of any kind.

# Install

## With Go

```
sudo GOBIN=/usr/local/bin go install -v github.com/williamhaley/backup/cmd/backup@latest
```

## From Source

```
make
sudo make install
```

# Test

```
make test
```

# Config

## Client

Config files should be located at `/etc/backup/...` and named with a `yaml` extension. See `backup.yaml.sample` as a reference.

Generate an SSH backup key with `ssh-keygen`. Move the generated files to `/etc/backup`. Reference the private key with the `key` config parameter.

See [backup-cron.sh](backup-cron.sh) for an example where the backup job is run in the background via `cron`.

A typical backup scheduled (for the `root` user at this time) might look like so.

```
0 */4 * * * /usr/local/bin/backup-cron.sh
```

## Server

Create a `config.toml` file in the `server` directory. Use `config.toml.sample` as a guide.

Build and deploy the `Dockerfile`, which will automatically generate users and `chroot` directories based on the configuration TOML file.

```
docker build --build-arg APK_ARCH=aarch64 --build-arg ALPINE_VERSION=v3.22 . -t backup-server
docker run \
    -p 49152:49152 \
    --name backup-server \
    --hostname backup-server \
    -v /my/persistent/storage/directory:/backups \
    -v /path/to/config.toml:/config.toml:ro \
    --privileged=true `# Needed for bind mounts` \
    backup-server
```

# Backup of Backups

The backups should all be backed up! Use `rsync` or whatever you like to make sure all the backups used by the server are backed up.

If using `btrfs` daily snapshots of backups could be created using something like [snapshot.sh](snapshot.sh) and a `cron` entry like so.

```
0 6 * * * /usr/local/bin/snapshot.sh
```