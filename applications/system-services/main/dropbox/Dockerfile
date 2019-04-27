FROM ubuntu:bionic

RUN apt-get -qqy update && \
    apt-get install -qqy wget && \
	apt-get -qqy autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd dropbox && \
    useradd -m -d /home/dropbox -c "Dropbox daemon" -s /usr/sbin/nologin -g dropbox dropbox

USER dropbox

WORKDIR /home/dropbox

RUN wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

ENTRYPOINT [".dropbox-dist/dropboxd"]
