FROM nickbreen/cron:v1.0.0

MAINTAINER Mathias Hansen <mathias@geocod.io>

RUN apt-get -qqy update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qqy install mysql-client wget && \
  apt-get -qqy clean

# Download newest version of jq
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/bin/jq && \
  chmod +x /usr/bin/jq

ENV MYSQL_HOSTNAME="" MYSQL_USERNAME="" MYSQL_PASSWORD="" FLUENTBIT_HOSTNAME="" FLUENTBIT_PORT="5170"

ENV CRON_D_MONITOR="*/5 * * * * root /monitor.sh | logger\n"

COPY monitor.sh /
