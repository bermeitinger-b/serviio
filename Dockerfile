FROM openjdk:alpine

# Serviio download
ENV SERVIIO_VERSION="2.1"
ENV SERVIIO_URL="http://download.serviio.org/releases/serviio-${SERVIIO_VERSION}-linux.tar.gz" \
	SERVIIO_MD5="31b82ca2cb472f7c055df933bf497690"

RUN apk add --update \
	curl \
    ffmpeg

RUN mkdir -p /app /config /defaults /app \
	&& curl -o /tmp/serviio.tar.gz -L ${SERVIIO_URL} \
	&& test ${SERVIIO_MD5} = $(md5sum /tmp/serviio.tar.gz | cut -d " " -f1) \
	&& tar xfz /tmp/serviio.tar.gz -C /app --strip-components=1 \
	&& rm -rf /tmp/*

COPY log4j.xml /config/serviio/config/

EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp

VOLUME /config

CMD java \
    -Djava.net.preferIPv4Stack=true \
    -Djava.awt.headless=true \
    -Dorg.restlet.engine.loggerFacadeClass=org.restlet.ext.slf4j.Slf4jLoggerFacade \
    -Dderby.system.home=/config/library \
    -Dserviio.home=/app \
    -Dplugins.location=/config/plugins \
    -Dserviio.defaultTranscodeFolder=/tmp \
    -Dffmpeg.location=/usr/bin/ffmpeg \
    -classpath "/app/lib/*:/app/config" \
    org.serviio.MediaServer
