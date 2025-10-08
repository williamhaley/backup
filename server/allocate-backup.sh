#!/usr/bin/env bash

set -e

name="${1}"
key="${2}"
group_name="backup-client"

echo "allocating backup config: '${name}'"

mkdir -p "/chroots/${name}"
rsync -ar /chroot-template/ "/chroots/${name}/"

# Create the destination mount point we will bind from persistent storage.
mkdir -p "/chroots/${name}/backup"

# User must exist in ${group_name} on the sshd server in order to authenticate.
useradd --no-create-home --groups "${group_name}" "${name}"

uid="$(id -u "${name}")"
chroot "/chroots/${name}" useradd --uid "${uid}" --create-home "${name}"

mount --bind "/backups/${name}" "/chroots/${name}/backup"

touch "/chroots/${name}/home/${name}/.hushlogin"

mkdir -p "/chroots/${name}/home/${name}/.ssh"
# Option for per-user restrictions instead of ForceCommand.
# printf 'command="/usr/local/bin/only.sh" %s\n' "${key}" > "/chroots/${name}/home/${name}/.ssh/authorized_keys"
printf '%s\n' "${key}" > "/chroots/${name}/home/${name}/.ssh/authorized_keys"
chmod 700 "/chroots/${name}/home/${name}/.ssh"
chmod 500 "/chroots/${name}/home/${name}/.ssh/authorized_keys"

chown -R "${name}:${name}" "/chroots/${name}/home/${name}"
