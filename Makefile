.PHONY: default run build

default: build 

build:
	docker build -t geocodio/docker-mysql-replication-monitor-fluentbit .

run:
	docker run --rm --name=replication-monitor --env-file=.env geocodio/docker-mysql-replication-monitor-fluentbit
