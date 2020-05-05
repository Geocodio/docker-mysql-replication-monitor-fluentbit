# MySQL Replication Monitor

This will monitor a MySQL slave server for errors and replication lag and send the results to [fluentbit](https://fluentbit.io).

## Configuration

```
MYSQL_HOSTNAME
MYSQL_USERNAME
MYSQL_PASSWORD
FLUENTBIT_HOSTNAME
FLUENTBIT_PORT="5170"
```

```
# Time is defined in seconds
TIME_BETWEEN_CHECKS=60
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
