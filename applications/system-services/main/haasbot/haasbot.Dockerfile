FROM mono:6.8

# Helpful sources (thanks!):
# - https://github.com/tonymorella/haasbot_docker/blob/master/Dockerfile
# - https://gist.github.com/R4stl1n/151f146ffca51268d323e39b56e91bab

RUN apt-get update && \
    apt-get -y install mono-4.0-service nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /haasbot/files

ADD haas-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Hosting 8092
# Hub 8090
# Local API 8060 (8050?)
EXPOSE 8090 8092

ENTRYPOINT ["/entrypoint.sh"]
