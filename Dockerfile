FROM openjdk:8-jre-alpine

# Serviio download
ARG SERVIIO_VERSION="2.0"
ARG SERVIIO_URL="http://download.serviio.org/releases/serviio-${SERVIIO_VERSION}-linux.tar.gz"

RUN apk add --no-cache \
        bash curl expat gmp gnutls jasper jpeg libbz2 libdrm libffi lcms2\ 
        libjpeg-turbo tar ca-certificates coreutils shadow tzdata \ 
    && mkdir -p /app /config /defaults \
    && mkdir -p /app/serviio \
    && curl -o /tmp/${SERVIIO_URL##*/} -L ${SERVIIO_URL} \
    && tar xfz /tmp/${SERVIIO_URL##*/} -C /app/serviio --strip-components=1 \
    && rm -rf /tmp/* 

COPY --from=jrottenberg/ffmpeg:4.2-scratch / /usr/
COPY log4j.xml /config/serviio/config/

EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp

VOLUME /config /transcode

WORKDIR /tmp

CMD java \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+UseCGroupMemoryLimitForHeap \
    -Djava.net.preferIPv4Stack=true \
    -Djava.awt.headless=true \
    -Dorg.restlet.engine.loggerFacadeClass=org.restlet.ext.slf4j.Slf4jLoggerFacade \
    -Dderby.system.home=/config/serviio/library \
    -Dserviio.home=/app/serviio \
    -Dplugins.location=/config/serviio \
    -Dserviio.defaultTranscodeFolder=/transcode \
    -Dffmpeg.location=/usr/bin/ffmpeg \
    -classpath "/app/serviio/lib/*:/app/serviio/config" \
    org.serviio.MediaServer
