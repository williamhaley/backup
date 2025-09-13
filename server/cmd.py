#!/usr/bin/env python3

import os
import subprocess
import sys
import tomllib

print('starting backup-server...')

config_file_path = sys.argv[1]

group_name = "backups"

subprocess.run(["groupadd", group_name])

with open(config_file_path, "rb") as config_file:
    data = tomllib.load(config_file)
    for backup in data['backups']:
        name = backup['name']
        key = backup['key']

        print('allocating backup config:', name)

        # TODO This is probably slow, and the chroot template could be smaller to speed up boot time.
        subprocess.run(["rsync", "-avr", "/chroot-template/", f"/chroots/{name}"])
        # Create the destination mount point we will bind from persistent storage.
        subprocess.run(["mkdir", "-p", f"/chroots/{name}/backup"])

        subprocess.run(["useradd", "--create-home", "--groups", group_name, name])
        subprocess.run(["cp", "/etc/hostname", f"/chroots/{name}/etc/hostname"])
        subprocess.run(["cp", "/etc/hosts", f"/chroots/{name}/etc/hosts"])

        subprocess.run(["chroot", f"/chroots/{name}", "groupadd", group_name])
        subprocess.run(["chroot", f"/chroots/{name}", "useradd", "--create-home", "--groups", group_name, name])
        subprocess.run(["mount", "--bind", f"/backups/{name}", f"/chroots/{name}/backup"])

        authorized_keys_file_path = f'/authorized_keys/{name}'
        os.makedirs(os.path.dirname(authorized_keys_file_path), exist_ok=True)
        with open(authorized_keys_file_path, 'w') as authorized_keys_file:
            authorized_keys_file.write(key)

        with open(f'/chroots/{name}/etc/sudoers.d/rrsync', 'w') as sudoers_file:
            sudoers_file.write(f'Defaults!/usr/bin/rrsync env_keep += "SSH_ORIGINAL_COMMAND"\n')
            sudoers_file.write(f'{name} ALL = (ALL) NOPASSWD: /usr/bin/rrsync\n')
            sudoers_file.write(f'{name} ALL = (ALL) NOPASSWD: /usr/bin/rsync\n')

subprocess.run(["/usr/sbin/sshd", "-D", "-e"])
