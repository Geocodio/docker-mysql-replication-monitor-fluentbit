FROM nickbreen/cron:v1.0.0

MAINTAINER Mathias Hansen <mathias@geocod.io>

RUN apt-get -qqy update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qqy install mysql-client && \
  apt-get -qqy clean

ENV MYSQL_HOSTNAME="" MYSQL_USERNAME="" MYSQL_PASSWORD="" FLUENTBIT_HOSTNAME="" FLUENTBIT_PORT="5170"

ENV CRON_D_BACKUP="*/5 * * * * root /monitor.sh | logger\n"

COPY monitor.sh /
