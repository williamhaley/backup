#!/usr/bin/env bash

set -e

uuid="${1}"
name="${2}"
key="${3}"
group_name="backup-client"

echo "allocating backup config: '${name}' (${uuid})"

mkdir -p "/chroots/${uuid}"
rsync -ar /chroot-template/ "/chroots/${uuid}/"

# Create the destination mount point we will bind from persistent storage.
mkdir -p "/chroots/${uuid}/backup"

# User must exist in ${group_name} on the sshd server in order to authenticate.
useradd --no-create-home --groups "${group_name}" "${uuid}"

uid="$(id -u "${uuid}")"
chroot "/chroots/${uuid}" useradd --uid "${uid}" --create-home "${uuid}"

mkdir -p "/backups/${uuid}"
mount --bind "/backups/${uuid}" "/chroots/${uuid}/backup"

touch "/chroots/${uuid}/home/${uuid}/.hushlogin"

mkdir -p "/chroots/${uuid}/home/${uuid}/.ssh"
# Option for per-user restrictions instead of ForceCommand.
# printf 'command="/usr/local/bin/only.sh" %s\n' "${key}" > "/chroots/${name}/home/${name}/.ssh/authorized_keys"
printf '%s\n' "${key}" > "/chroots/${uuid}/home/${uuid}/.ssh/authorized_keys"
chmod 700 "/chroots/${uuid}/home/${uuid}/.ssh"
chmod 500 "/chroots/${uuid}/home/${uuid}/.ssh/authorized_keys"

chown -R "${uuid}:${uuid}" "/chroots/${uuid}/home/${uuid}"
