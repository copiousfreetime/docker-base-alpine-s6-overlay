##
## Modified from https://github.com/harningt/docker-base-alpine-s6-overlay
##

FROM alpine:3.8
MAINTAINER Jeremy Hinegardner <jeremy@copiousfreetime.org>

##
## Install the base apk packages needed for s6
##

RUN apk add --no-cache \
  s6 \
  s6-dns \
  s6-linux-utils \
  s6-networking \
  s6-portable-utils \
  s6-rc

##
## Upstream Overlay Version and code, download all of it and verify
##
ENV S6_OVERLAY_RELEASE v1.21.7.0
ENV TMP_BUILD_DIR /tmp/build

ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz.sig ${TMP_BUILD_DIR}/
ADD https://keybase.io/justcontainers/key.asc ${TMP_BUILD_DIR}/

RUN apk add --no-cache --virtual verify gnupg && \
  chmod 0700 ${TMP_BUILD_DIR} && \
  cd ${TMP_BUILD_DIR} && \
  gpg --options /dev/null \
      --homedir ${TMP_BUILD_DIR} \
      --no-default-keyring \
      --keyring ${TMP_BUILD_DIR}/keyring \
      --import ${TMP_BUILD_DIR}/key.asc && \
  gpg --options /dev/null \
      --homedir ${TMP_BUILD_DIR} \
      --no-default-keyring \
      --keyring ${TMP_BUILD_DIR}/keyring \
      --no-auto-check-trustdb \
      --trust-model always \
      --verify s6-overlay-nobin.tar.gz.sig \
      s6-overlay-nobin.tar.gz && \
  apk del verify && \
  tar -C / -zxf s6-overlay-nobin.tar.gz && \
  cd / && \
  rm -rf ${TMP_BUILD_DIR}


##
## INIT
##

ENTRYPOINT [ "/init" ]
