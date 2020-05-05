FROM alpine:3.11

MAINTAINER Mathias Hansen <mathias@geocod.io>

RUN apk add --no-cache mysql-client wget bash && \
    rm -f /var/cache/apk/*

# Download newest version of jq
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/bin/jq && \
  chmod +x /usr/bin/jq

ENV MYSQL_HOSTNAME="" MYSQL_USERNAME="" MYSQL_PASSWORD="" FLUENTBIT_HOSTNAME="" FLUENTBIT_PORT="5170"

ENV TIME_BETWEEN_CHECKS=60

COPY monitor.sh /monitor.sh
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "entrypoint.sh"]