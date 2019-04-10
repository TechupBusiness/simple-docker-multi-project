FROM alpine:latest

ARG UID=1000
ARG GID=1000

RUN apk update && \
    apk upgrade && \
    apk add --no-cache mariadb-client

# Only temporary - will be replaced by docker-compose volume link
ADD template/crontab.txt /cronjobs/crontab.txt
ADD template/daily/database-backup.sh /cronjobs/daily/database-backup.sh

COPY entry-command.sh /entry-command.sh

RUN  chmod -R a+x /cronjobs && \
     /usr/bin/crontab /cronjobs/crontab.txt && \
     chmod 755 /entry-command.sh && \
     addgroup -g $GID jobs && \
     adduser -D -u $UID -G jobs jobs && \
     chown -R jobs:jobs /cronjobs && \
     mkdir -p /home/backup && \
     chown -R jobs:jobs /home/backup

USER jobs

CMD ["/entry-command.sh"]
