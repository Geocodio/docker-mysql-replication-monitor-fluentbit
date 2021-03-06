.PHONY: default build deploy run

default: build

org = geocodio
name = docker-mysql-replication-monitor-fluentbit

build:
	docker build -t $(org)/$(name) .

deploy:
	docker push $(org)/$(name)

run:
	docker run -it --rm --name=$(name) --env-file=.env $(org)/$(name)
