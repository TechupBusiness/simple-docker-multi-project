FROM liiight/notifiers

ARG NOTIFIERS_USER="notifier"
ARG NOTIFIERS_PASSWORD="notifier"
ARG NOTIFIERS_PORT=3222

# Install ssh to allow notifications via command-line call from other containers
RUN apk add --update --no-cache openssh && \
    rm  -rf /tmp/* /var/cache/apk/*

# Make sure there is no key and set custom port
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key && \
    echo "Port $NOTIFIERS_PORT" >> /etc/ssh/sshd_config

EXPOSE $NOTIFIERS_PORT

ADD notify.sh /notifiers

# Create a group and user
RUN addgroup -S $NOTIFIERS_USER && \
    adduser -S $NOTIFIERS_USER -G $NOTIFIERS_USER -h /notifiers -s /bin/sh && \
    echo $NOTIFIERS_USER:$NOTIFIERS_PASSWORD | chpasswd && \
    chown -R $NOTIFIERS_USER:$NOTIFIERS_USER /notifiers

# add entrypoint script
ADD docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd","-D"]
