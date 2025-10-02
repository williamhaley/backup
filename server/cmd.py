#!/usr/bin/env python3

import os
import subprocess
import sys
import tomllib

config_file_path = sys.argv[1]

group_name = "backup-client"

subprocess.run(["groupadd", group_name])

# TODO Validate no duplicate `name` entries or the last one clobbers earlier ones.

with open(config_file_path, "rb") as config_file:
    data = tomllib.load(config_file)
    for backup in data['backups']:
        name = backup['name']
        key = backup['key']

        result = subprocess.run(["/usr/local/bin/allocate-backup.sh", name, key])
        if result.returncode != 0:
            print(f"error allocating backup for: '{name}'")
            sys.exit(1)

        # with open(f'/chroots/{name}/etc/sudoers.d/rrsync', 'w') as sudoers_file:
        #     sudoers_file.write(f'Defaults!/usr/bin/rrsync env_keep += "SSH_ORIGINAL_COMMAND"\n')
        #     sudoers_file.write(f'{name} ALL = (ALL) NOPASSWD: /usr/bin/rrsync\n')
        #     sudoers_file.write(f'{name} ALL = (ALL) NOPASSWD: /usr/bin/rsync\n')

result = subprocess.run(["/usr/sbin/sshd", "-p", "49152", "-D", "-e"])
if result.returncode != 0:
    print('server error!')
    sys.exit(1)
