FROM debian:latest AS chroot-builder

RUN apt-get update && apt-get install -y debootstrap

# python3 is needed for the rrsync script.
RUN debootstrap --include=rsync,sudo,python3 --variant=minbase stable /chroot-template http://deb.debian.org/debian/

FROM debian:latest

RUN apt-get update && apt-get install -y openssh-server openssl python3 rsync

COPY --from=chroot-builder /chroot-template /chroot-template

COPY sshd_config /etc/ssh/
COPY config.toml /config.toml
COPY cmd.py /usr/local/bin/

# cmd.py and all the chroots and users are ephemeral. Only the data is persisted and mounted at run time.
CMD ["/usr/bin/python3", "-u", "/usr/local/bin/cmd.py", "/config.toml"]
