FROM jrottenberg/ffmpeg:snapshot-alpine

MAINTAINER "Zimmermann Zsolt"

# package versions
ARG SERVIIO_VER="1.9.2"
ARG OVERLAY_VERSION="v1.21.4.0"
ARG OVERLAY_ARCH="amd64"

# environment settings
ENV JAVA_HOME="/usr/bin/java"
ENV SERVIIO_OPTS=" "

COPY patches/ /tmp/patches/

RUN apk add --no-cache --virtual=build-dependencies gcc jasper-dev jpeg-dev make libc-dev lcms2-dev
RUN cp /tmp/patches/dcraw.c /usr/bin/dcraw.c && cd /usr/bin && gcc -o dcraw -O4 dcraw.c -lm -ljasper -ljpeg -llcms2 
RUN apk del --purge build-dependencies

RUN apk update && apk upgrade
# alsa-lib expat gmp  gnutls  jasper  jpeg  lame  lcms2  libass  libbz2  libdrm  libffi  libgcc \
# libjpeg-turbo libogg libpciaccess librtmp libstdc++ libtasn1 libtheora libva libvorbis libvpx libx11 libxau libxcb libxdamage libxdmcp libxext libxfixes libxshmfence libxxf86vm mesa-gl \
# mesa-glapi nettle  opus p11-kit sdl ttf-dejavu v4l-utils-libs x264-libs  xvidcore
RUN apk add --no-cache openjdk8-jre x265 x264 curl tar bash ca-certificates coreutils shadow tzdata
RUN curl -o /tmp/s6-overlay.tar.gz -L "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz"
RUN tar xfz /tmp/s6-overlay.tar.gz -C / 
RUN groupmod -g 1000 users 
RUN useradd -u 911 -U -d /config -s /bin/false abc 
RUN usermod -G users abc 
RUN mkdir -p /app /config /defaults
RUN usermod -d /config/serviio abc
RUN mkdir -p /app/serviio 
RUN curl -o /tmp/serviio.tar.gz -L "http://download.serviio.org/releases/serviio-${SERVIIO_VER}-linux.tar.gz"
RUN tar xf /tmp/serviio.tar.gz -C /app/serviio --strip-components=1 
RUN rm -rf /tmp/*

# add local files
COPY root/ /
WORKDIR /tmp
CMD [""]
ENTRYPOINT ["/init"]

# ports and volumes
EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp
VOLUME /config /transcode
