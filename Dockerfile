FROM jrottenberg/ffmpeg:4.0-alpine

MAINTAINER "Zimmermann Zsolt"

# package versions
ARG SERVIIO_VER="1.9.2"
ARG OVERLAY_VERSION="v1.21.4.0"
ARG OVERLAY_ARCH="amd64"

# environment settings
ENV JAVA_HOME="/usr/bin/java"

RUN apk add --no-cache curl tar bash ca-certificates coreutils shadow tzdata alsa-lib expat gmp  gnutls  jasper  jpeg  lame  lcms2  libass  libbz2  libdrm  libffi  libgcc \
                       libjpeg-turbo libogg libpciaccess \librtmp libstdc++ libtasn1 libtheora libva libvorbis libvpx libx11 libxau libxcb libxdamage libxdmcp libxext libxfixes libxshmfence libxxf86vm mesa-gl \
                       mesa-glapi nettle openjdk8-jre opus p11-kit sdl ttf-dejavu v4l-utils-libs x264-libs x265 xvidcore 
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

# ports and volumes
EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp
VOLUME /config /transcode
