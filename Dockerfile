FROM jrottenberg/ffmpeg:snapshot-alpine

MAINTAINER "Zimmermann Zsolt"

# package versions
ARG SERVIIO_VER="1.9.2"
ARG OVERLAY_VERSION="v1.21.4.0"
ARG OVERLAY_ARCH="amd64"

# environment settings
ENV JAVA_HOME="/usr/bin/java"
ENV SERVIIO_OPTS=" "

ENV JAVA_MAX_MEM=1024M
ENV JAVA_START_MEM=20M

COPY patches/dcraw.c /usr/bin/

RUN apk add --no-cache --virtual=build-dependencies gcc jasper-dev jpeg-dev make libc-dev lcms2-dev \
    && cd /usr/bin && gcc -v -o dcraw -O4 dcraw.c -lm -ljasper -ljpeg -llcms2 \
    && apk del --purge build-dependencies

RUN apk update && apk upgrade \
    && apk add --no-cache openjdk8-jre x265 x264 curl tar bash ca-certificates coreutils shadow tzdata libjasper \
    && curl -o /tmp/s6-overlay.tar.gz -L "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && tar xfz /tmp/s6-overlay.tar.gz -C / \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc \
    && mkdir -p /app /config /defaults \
    && usermod -d /config/serviio abc \
    && mkdir -p /app/serviio \
    && curl -o /tmp/serviio.tar.gz -L "http://download.serviio.org/releases/serviio-${SERVIIO_VER}-linux.tar.gz" \
    && tar xf /tmp/serviio.tar.gz -C /app/serviio --strip-components=1 \
    && rm -rf /tmp/* 
COPY log4j.xml /config/serviio/config

# add local files
COPY root/ /
WORKDIR /tmp
CMD [""]
ENTRYPOINT ["/init"]

# ports and volumes
EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp
VOLUME /config /transcode


# alsa-lib expat gmp  gnutls  jasper  jpeg  lame  lcms2  libass  libbz2  libdrm  libffi  libgcc \
# libjpeg-turbo libogg libpciaccess librtmp libstdc++ libtasn1 libtheora libva libvorbis libvpx libx11 libxau libxcb libxdamage libxdmcp libxext libxfixes libxshmfence libxxf86vm mesa-gl \
# mesa-glapi nettle  opus p11-kit sdl ttf-dejavu v4l-utils-libs x264-libs  xvidcore
