ARG GRIST_VERSION=latest

FROM gristlabs/grist:$GRIST_VERSION

ARG UID=0
ARG GID=0

# TODO Add additional needed libs here https://support.getgrist.com/self-managed/#how-do-i-add-more-python-packages
RUN \
  apt update && apt install -y openssl && \
  python3 -m pip install phonenumbers