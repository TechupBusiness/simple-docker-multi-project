FROM alpine:latest

ARG UID=1000
ARG GID=1000
ARG POSTGRES_BACKUP_HOUR=2

RUN apk add --no-cache postgresql-client

RUN echo "0       ${POSTGRES_BACKUP_HOUR}       *       *       *       run-parts /cronjobs/daily" >> /etc/crontabs/jobs
RUN echo "" > /etc/crontabs/root
COPY database-backup.sh /cronjobs/daily/database-backup

RUN  chmod -R a+x /cronjobs/ && \
     addgroup -g $GID jobs && \
     adduser -D -u $UID -G jobs jobs && \
     chown -R jobs:jobs /cronjobs && \
     mkdir /backups && \
     chown -R jobs:jobs /backups

CMD ["/usr/sbin/crond -f -d 8"]
