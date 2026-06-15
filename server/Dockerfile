FROM debian:13.5 AS chroot-builder

RUN apt-get update && apt-get install -y ca-certificates

ARG APK_ARCH
ARG ALPINE_VERSION

# https://wiki.alpinelinux.org/wiki/Alpine_Linux_in_a_chroot
ADD https://gitlab.alpinelinux.org/api/v4/projects/5/packages/generic/v3.0.6/${APK_ARCH}/apk.static /chroot-template/sbin/apk
RUN chmod +x /chroot-template/sbin/apk
RUN /chroot-template/sbin/apk \
    --repository https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
    --repository https://dl-cdn.alpinelinux.org/alpine/latest-stable/community \
    -U \
    --allow-untrusted \
    --root /chroot-template \
    --initdb \
    add alpine-base shadow sudo rsync rrsync

COPY only.sh /chroot-template/usr/local/bin/

COPY <<EOF /chroot-template/etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/main
https://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/community
EOF

COPY <<EOF /chroot-template/etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

COPY <<EOF /chroot-template/etc/sudoers.d/rrsync
Defaults!/usr/bin/rrsync env_keep += "SSH_ORIGINAL_COMMAND"
%sudo ALL = (ALL) NOPASSWD: /usr/bin/rrsync
EOF

RUN bash <<EOF
chroot /chroot-template groupadd sudo
EOF

FROM debian:13.5

RUN apt-get update && apt-get install -y openssh-server openssl python3 rsync

COPY --from=chroot-builder /chroot-template /chroot-template

COPY sshd_config /etc/ssh/sshd_config.d/backups.conf
COPY cmd.py /usr/local/bin/
COPY allocate-backup.sh /usr/local/bin/

ENV PYTHONUNBUFFERED=1

# cmd.py and all the chroots and users are ephemeral. Only the data is persisted and mounted at run time.
CMD ["/usr/bin/python3", "-u", "/usr/local/bin/cmd.py", "/config.toml"]
