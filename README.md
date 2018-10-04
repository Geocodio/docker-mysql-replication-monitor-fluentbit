# MySQL Replication Monitor

This will monitor a MySQL slave server for errors and replication lag and send the results to [fluentbit](https://fluentbit.io).

## Configuration

Per default, a cronjob will run every 5 minutes, but any of the settings can be overwritten with the following environment variables:

```
MYSQL_HOSTNAME
MYSQL_USERNAME
MYSQL_PASSWORD
FLUENTBIT_HOSTNAME
FLUENTBIT_PORT="5170"
```

```
CRON_D_MONITOR="*/5 * * * * root /monitor.sh | logger\n"
```

> See also `.env.example`

## Releasing

```
# Build docker image
make build

# Push docker image
make deploy

# Run docker image (using .env file)
make run
```
