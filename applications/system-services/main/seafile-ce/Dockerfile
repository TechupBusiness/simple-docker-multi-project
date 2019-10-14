###################################
# Base image and preparations
###################################

FROM ubuntu:latest

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG SEAFILE_VERSION=7.0.5

# Installation source https://download.seafile.com/published/seafile-manual/deploy/using_mysql.md
RUN apt-get -qqy update && \
    apt-get install -qqy wget python python2.7 libpython2.7 python-setuptools python-ldap python-urllib3 ffmpeg python-pip python-mysqldb python-memcache python-requests locales && \
    pip install Pillow==4.3.0 && \
    pip install moviepy \
    # Add memcached (https://download.seafile.com/published/seafile-manual/deploy/add_memcached.md)
    pip install pylibmc \
    pip install django-pylibmc

RUN groupadd -g $GID seafile && \
    useradd -u $UID -m -d /home/seafile -c "Seafile user" -s /usr/sbin/nologin -g seafile seafile

USER seafile

ADD ./scripts /

WORKDIR /home/seafile

###################################
# Download & unzip application
###################################

# See https://download.seafile.com/published/seafile-manual/deploy/using_mysql.md for details (following best practice)
RUN wget "https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz" && \
    tar xvzf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    mkdir installed && \
    mv seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz installed && \

# Cleanup
RUN     apt-get -qqy autoclean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*