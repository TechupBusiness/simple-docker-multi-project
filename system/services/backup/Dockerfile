FROM alpine:latest

RUN apk add --update --no-cache ca-certificates fuse openssh-client curl bzip2 bash unzip ssmtp openssh sshpass

VOLUME /root

# Note: "run-parts" command in crontab does not support *.sh extension
COPY backup.sh /etc/periodic/daily/backup
COPY cleanup.sh /etc/periodic/weekly/cleanup

# Download & install rclone and restic
RUN     cd /root && \
        # Download rclone
        curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
        unzip rclone-current-linux-amd64.zip && \
        # Install rclone
        cd rclone-*-linux-amd64 && \
        cp rclone /usr/bin/ && \
        chmod 755 /usr/bin/rclone && \
        # Download restic latest release
        curl --silent "https://api.github.com/repos/restic/restic/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' | \
            xargs -I {} curl -sOL "https://github.com/restic/restic/releases/download/v"{}'/restic_'{}'_linux_amd64.bz2' && \
        bzip2 -d restic_*.bz2 && \
        # Install restic
        mv restic_* /usr/bin/restic && \
        chmod 755 /usr/bin/restic && \
        # Add cronjobs
        chmod +x /etc/periodic/weekly/cleanup && \
        chmod +x /etc/periodic/daily/backup && \
        # Add ssh config (see https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html#sftp )
        mkdir -p /root/.ssh && \
        touch /root/.ssh/config && \
        echo 'ServerAliveInterval 60' >> /root/.ssh/config && \
        echo 'ServerAliveCountMax 240' >> /root/.ssh/config && \
        # Set weekly to midnight, as the backup starts as 2 and keeps often running longer than 3am
        sed -i "s|3|0|g" /etc/crontabs/root

COPY entrypoint.sh /

ENTRYPOINT "/entrypoint.sh"
