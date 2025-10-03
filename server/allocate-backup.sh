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

useradd --create-home --groups "${group_name}" "${name}"

chroot "/chroots/${name}" groupadd "${group_name}"
chroot "/chroots/${name}" useradd --create-home --groups "${group_name}" "${name}"

mount --bind "/backups/${name}" "/chroots/${name}/backup"

mkdir -p "/chroots/${name}/home/${name}/.ssh"

# This is how a user gets restricted to a specific command.
printf 'command="/usr/bin/sudo /usr/bin/rrsync -wo /backup" %s\n' "${key}" > "/chroots/${name}/home/${name}/.ssh/authorized_keys"
# Allow a user to log in without restrictions and then run any command.
# printf '%s\n' "${key}" > "/chroots/${name}/home/${name}/.ssh/authorized_keys"

touch "/chroots/${name}/home/${name}/.hushlogin"
chmod 700 "/chroots/${name}/home/${name}/.ssh"
chmod 500 "/chroots/${name}/home/${name}/.ssh/authorized_keys"

chown -R "${name}:${name}" "/chroots/${name}/home/${name}"
