# Backup

Semi-complicated scripts, applications, and other helpers used for backing up my systems. This is a personal project with no support, guarantees, or assurances of any kind.

# Install

## Go

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

Generate an SSH backup key with `ssh-keygen`. Move the generated files to `/etc/backup`. Reference the private key with the `destination_key` config parameter.

## Server

Create a `config.toml` file in the `server` directory. Use `config.toml.sample` as a guide.

Build and deploy the `Dockerfile`, which will automatically generate users and `chroot` directories based on the configuration TOML file.

```
docker build . -t backup-server
docker run \
    -p 2222:22 \
    --name backup-server \
    --hostname backup-server \
    -v /my/persistent/storage/directory:/backups \
    --privileged=true `# Needed for bind mounts` \
    backup-server
```

# Backup of Backups

The backups should all be backed up! Use `rsync` or whatever you like to make sure all the backups used by the server are backed up.
