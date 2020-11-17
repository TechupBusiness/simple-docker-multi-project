FROM golang AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /src

ENV CGO_ENABLED=0
ENV BUILD_HOST=syncthing.net
ENV BUILD_USER=docker

RUN curl -L https://github.com/syncthing/syncthing/archive/`git ls-remote https://github.com/syncthing/syncthing | grep refs/tags | grep -oP "v[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`.tar.gz | tar vxz --strip-components=1
RUN go run build.go -no-upgrade build strelaysrv

FROM syncthing/syncthing

COPY --from=builder /src/strelaysrv /bin/strelaysrv
COPY ./docker-entrypoint.sh /bin/entrypoint.sh

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z 127.0.0.1 22070 || exit 1

ENTRYPOINT ["/bin/entrypoint.sh", "-pools="]
