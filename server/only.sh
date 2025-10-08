#!/bin/sh

set -e

# https://stackoverflow.com/questions/12346769/ssh-forced-command-parameters
# https://at.magma-soft.at/sw/blog/posts/The_Only_Way_For_SSH_Forced_Commands/

allowed_commands="rsync whoami"

set -- $SSH_ORIGINAL_COMMAND

if [ -z "${1}" ]
then
    echo "Successfully authenticated as '$(whoami)', but no valid command specified"
    exit 0
fi

for command in ${allowed_commands}
do
    if [ "${1}" = "rsync" ]
    then
        exec /usr/bin/sudo /usr/bin/rrsync -wo /backup
    elif [ "$1" = "${command}" ]
    then
        exec "$@"
    fi
done

echo "invalid command" >&2
exit 1
