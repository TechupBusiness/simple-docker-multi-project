FROM ubuntu:bionic

ARG DROPBOX_LOCALE=en_US.utf8
ARG UID="1000"
ARG GID="1000"

RUN apt-get -qqy update && \
    apt-get install -qqy wget python python3 locales

RUN groupadd -g $GID dropbox && \
    useradd -u $UID -m -d /home/dropbox -c "Dropbox daemon" -s /usr/sbin/nologin -g dropbox dropbox && \
    wget -O /usr/local/bin/dropbox "https://linux.dropbox.com/packages/dropbox.py" && \
    chmod +x /usr/local/bin/dropbox && \
    apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER dropbox
WORKDIR /home/dropbox

RUN mkdir -p /home/dropbox/.dropbox && \
    wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

ENTRYPOINT [".dropbox-dist/dropboxd"]
