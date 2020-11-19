FROM nginx:alpine

ARG UID=82
ARG GID=82

COPY nginx.conf /nginx.conf.template
COPY nginx-entrypoint.sh /nginx-entrypoint.sh

RUN chmod +x /nginx-entrypoint.sh

RUN apk --no-cache add shadow \
 && usermod -u ${UID} nginx \
 && groupmod -g ${GID} nginx

ENTRYPOINT ["/nginx-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
