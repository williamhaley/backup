FROM debian:13.1 AS chroot-builder

RUN apt-get update && apt-get install -y ca-certificates

# https://wiki.alpinelinux.org/wiki/Alpine_Linux_in_a_chroot
ADD https://gitlab.alpinelinux.org/api/v4/projects/5/packages/generic//v2.14.10/x86_64/apk.static /chroot-template/sbin/apk
RUN chmod +x /chroot-template/sbin/apk
RUN /chroot-template/sbin/apk \
    --repository https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
    --repository https://dl-cdn.alpinelinux.org/alpine/latest-stable/community \
    -U \
    --allow-untrusted \
    --root /chroot-template \
    --initdb \
    add alpine-base rsync shadow sudo rrsync

COPY <<EOF /chroot-template/etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/v3.22/main
https://dl-cdn.alpinelinux.org/alpine/v3.22/community
EOF

COPY <<EOF /chroot-template/etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

COPY <<EOF /chroot-template/etc/sudoers.d/rrsync
Defaults!/usr/bin/rrsync env_keep += "SSH_ORIGINAL_COMMAND"
%backup-client ALL = (ALL) NOPASSWD: /usr/bin/rrsync
EOF

COPY <<EOF /chroot-template/etc/sudoers.d/rsync
%backup-client ALL = (ALL) NOPASSWD: /usr/bin/rsync
EOF

COPY <<EOF /chroot-template/etc/sudoers.d/whoami
%backup-client ALL = (ALL) NOPASSWD: /usr/bin/whoami
EOF

# COPY ./copy-app.sh /usr/local/bin/
# RUN copy-app.sh sh
# RUN copy-app.sh mkdir
# RUN copy-app.sh cat
# RUN copy-app.sh bash
# RUN copy-app.sh ls
# RUN copy-app.sh rsync
# RUN cp /usr/bin/rrsync /chroot-template/usr/bin/
# RUN copy-app.sh python3
# RUN copy-app.sh groupadd
# RUN copy-app.sh useradd
# RUN copy-app.sh su

FROM debian:13.1

RUN apt-get update && apt-get install -y openssh-server openssl python3 rsync

COPY --from=chroot-builder /chroot-template /chroot-template

COPY sshd_config /etc/ssh/sshd_config.d/backups.conf
COPY config.toml /config.toml
COPY cmd.py /usr/local/bin/
COPY allocate-backup.sh /usr/local/bin/

ENV PYTHONUNBUFFERED=1

# cmd.py and all the chroots and users are ephemeral. Only the data is persisted and mounted at run time.
CMD ["/usr/bin/python3", "-u", "/usr/local/bin/cmd.py", "/config.toml"]
