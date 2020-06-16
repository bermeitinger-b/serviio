FROM openjdk:8-jre

# Serviio download
ARG SERVIIO_VERSION="2.1"
ARG SERVIIO_URL="http://download.serviio.org/releases/serviio-${SERVIIO_VERSION}-linux.tar.gz"
ARG SERVIIO_MD5="31b82ca2cb472f7c055df933bf497690"

RUN apt-get update
RUN apt-get install -y \
       ffmpeg 

RUN mkdir -p /app /config /defaults \
    && mkdir -p /app/serviio \
    && curl -o /tmp/serviio.tar.gz -L ${SERVIIO_URL} \
    && test ${SERVIIO_MD5} = $(md5sum /tmp/serviio.tar.gz | cut -d " " -f1) \
    && tar xfz /tmp/serviio.tar.gz -C /app/serviio --strip-components=1 \
    && rm -rf /tmp/*

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
