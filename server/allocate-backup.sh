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

cp /etc/hostname "/chroots/${name}/etc/hostname"
cp /etc/hosts "/chroots/${name}/etc/hosts"

chroot "/chroots/${name}" groupadd "${group_name}"
chroot "/chroots/${name}" useradd --create-home --groups "${group_name}" "${name}"
# chroot "/chroots/${name}" passwd -u "${name}"

mount --bind "/backups/${name}" "/chroots/${name}/backup"

mkdir -p "/chroots/${name}/home/${name}/.ssh"
printf "%s\n" "${key}" > "/chroots/${name}/home/${name}/.ssh/authorized_keys"

touch  "/chroots/${name}/home/${name}/.hushlogin"
chmod 700 "/chroots/${name}/home/${name}/.ssh"
chmod 500 "/chroots/${name}/home/${name}/.ssh/authorized_keys"
chown -R "${name}:${name}" "/chroots/${name}/home/${name}"

