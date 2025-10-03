#!/usr/bin/env bash

set -e

app="${1}"
is_link=false

if [ -L "$(which "${1}")" ]
then
    app="$(basename "$(readlink -f "$(which "${1}")")")"
    echo "'${1}' is a symbolic link. using "${app}" instead"
    is_link=true
fi

full_path="$(which "${app}")"
base_path="$(dirname "${full_path}")"
mkdir -p "/chroot-template/${base_path}"

cp --preserve=mode,ownership,timestamps "${base_path}/${app}" "/chroot-template/${base_path}/"

full_path="$(which "${app}")"
libs="$(ldd "${full_path}" | awk '{print $3}' | grep -v '^$' | sort -u)"
for lib in $libs
do
    cp -L --parents "${lib}" /chroot-template
done

ld_linux="$(ldd "${full_path}" | grep "ld-linux" | awk '{print $1}')"
if [ -n "${ld_linux}" ]
then
    cp -L --parents "${ld_linux}" /chroot-template
fi

ld_linux_64="$(ldd "${full_path}" | grep "ld-linux" | awk '{print $1}' | grep "64")"
if [ -n "${ld_linux_64}" ]
then
    cp -L --parents "${ld_linux_64}" /chroot-template
fi

if [ "${is_link}" == "true" ]
then
    ln -s "${full_path}" /chroot-template/"$(which "${1}")"
fi