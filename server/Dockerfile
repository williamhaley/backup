FROM debian:latest AS chroot-builder

RUN apt-get update && apt-get install -y python3 sudo rsync

RUN <<EOF
#!/usr/bin/env bash
set -e

function cp_app()
{
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
}

mkdir -p /chroot-template/{bin,etc,lib,lib64}

cp_app sh
cp_app bash
cp_app ls
cp_app rsync
cp_app sudo
cp_app python3
cp_app groupadd
cp_app useradd
cp_app passwd
cp_app id
cp_app su
cp_app whoami

ln -s "$(readlink -f "$(which sh)")" /chroot-template/bin/sh

cp /etc/sudoers /chroot-template/etc/
cp /etc/sudo.conf /chroot-template/etc/
mkdir /chroot-template/etc/sudoers.d
EOF

FROM debian:latest

RUN apt-get update && apt-get install -y openssh-server openssl python3 rsync

COPY --from=chroot-builder /chroot-template /chroot-template

COPY sshd_config /etc/ssh/sshd_config.d/backups.conf
COPY config.toml /config.toml
COPY cmd.py /usr/local/bin/
COPY allocate-backup.sh /usr/local/bin/

ENV PYTHONUNBUFFERED=1

# cmd.py and all the chroots and users are ephemeral. Only the data is persisted and mounted at run time.
CMD ["/usr/bin/python3", "-u", "/usr/local/bin/cmd.py", "/config.toml"]
