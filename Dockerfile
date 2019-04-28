FROM alpine:3.8 as buildstage

MAINTAINER "Zimmermann Zsolt"

COPY opensource.sh /tmp

RUN apk --no-cache update && apk --no-cache upgrade && apk add bash x265 ca-certificates coreutils shadow tzdata jasper-libs \
    && chmod u+x /tmp/opensource.sh \
    && /tmp/opensource.sh 

##################################################################################################################################

FROM anapsix/alpine-java:8u191b12_server-jre

# Serviio download
ARG SERVIIO_VERSION="1.10.1"
ARG SERVIIO_URL="http://download.serviio.org/releases/serviio-${SERVIIO_VERSION}-linux.tar.gz"

# Overlay download
ARG OVERLAY_VERSION="v1.21.8.0"
ARG OVERLAY_ARCH="amd64"
ARG OVERLAY_URL="https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz"

# Environment settings
ENV SERVIIO_OPTS=""
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
HOME="/root" \
TERM="xterm"

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing alsa-lib bash curl expat gmp gnutls jasper jpeg lcms2 \ 
    libbz2 libdrm libffi libgcc libjpeg-turbo libpciaccess libstdc++ libtasn1 libtheora libva libvorbis libvpx libx11 libxau libxcb \
    libxdamage libxdmcp libxext libxfixes libxshmfence libxxf86vm mesa-gl mesa-glapi nettle opus p11-kit v4l-utils-libs libc-dev fribidi openssl-dev\
    expat fdk-aac libtheora libvorbis tar ca-certificates coreutils shadow tzdata \ 
    && curl -o /tmp/${OVERLAY_URL##*/} -L ${OVERLAY_URL} \
    && tar xfz /tmp/${OVERLAY_URL##*/} -C / \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc \
    && mkdir -p /app /config /defaults \
    && usermod -d /config/serviio abc \
    && mkdir -p /app/serviio \
    && curl -o /tmp/${SERVIIO_URL##*/} -L ${SERVIIO_URL} \
    && tar xfz /tmp/${SERVIIO_URL##*/} -C /app/serviio --strip-components=1 \
    && rm -rf /tmp/*

COPY --from=buildstage /tmp/opensource/destination/usr/ /usr/
COPY log4j.xml /config/serviio/config/
COPY root/ /
EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp
VOLUME /config /transcode
WORKDIR /tmp
ENTRYPOINT ["/init"]
