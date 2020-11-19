FROM alpine:latest

ARG UID=1000
ARG GID=1000

RUN apk update && \
    apk upgrade && \
    apk add --no-cache sudo

# Only temporary - will be replaced by docker-compose volume link
ADD crontab.txt /cronjobs/config/crontab.txt
ADD template /cronjobs/jobs

COPY entry-command.sh /entry-command.sh

RUN  chmod -R a+x /cronjobs && \
     /usr/bin/crontab /cronjobs/config/crontab.txt && \
     chmod 755 /entry-command.sh && \
     addgroup -g $GID jobs && \
     adduser -D -u $UID -G jobs jobs && \
     chown -R jobs:jobs /cronjobs

USER jobs

CMD ["/entry-command.sh"]

#TODO - how can user setup this conatiner and add their own functionality needed for the cron-scripts?
