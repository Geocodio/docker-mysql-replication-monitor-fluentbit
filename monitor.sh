#!/bin/bash
## Based on original script by Joel Chaney, joel.chaney@mongoosemetrics.com, 2012-02-03

function send_status {
    STATUS="$*"

    echo "Sending status $STATUS"
    echo $STATUS | nc $FLUENTBIT_HOSTNAME $FLUENTBIT_PORT
}

function safe_command {
  typeset cmnd="$*"
  typeset ret_code

  eval $cmnd
  ret_code=$?
  if [ $ret_code != 0 ]; then
    printf "Error : [%d] when executing command: '$cmnd'" $ret_code
    STATUS="{\"success\": false, \"message\": \"Command failed with exit code $ret_code\"}"

    send_status $STATUS

    exit $ret_code
  fi
}

function extract_value {
    FILENAME=$1
    VAR=$2
    grep -w $VAR $FILENAME | awk '{print $2}'
}

function json_array() {
  printf '%s\n' "${X[@]}" | jq -R . | jq -s .
}

SLAVE_STATUS=/tmp/sstatus

SLAVE="mysql -u $MYSQL_USERNAME -p'$MYSQL_PASSWORD' -h $MYSQL_HOSTNAME"

MYSQL_STATUS_COMMAND="$SLAVE -e 'SHOW SLAVE STATUS\G' > $SLAVE_STATUS"
safe_command $MYSQL_STATUS_COMMAND

STATUS_FILESIZE=$(stat -c%s "$SLAVE_STATUS")

if [[ $STATUS_FILESIZE -lt 5 ]]
then
    STATUS="{\"success\": false, \"message\": \"SHOW SLAVE STATUS returned no data\"}"
    send_status $STATUS

    exit 1
fi

Master_Binlog=$(extract_value $SLAVE_STATUS Master_Log_File )
Master_Host=$(extract_value $SLAVE_STATUS Master_Host)
Master_Port=$(extract_value $SLAVE_STATUS Master_Port)
Master_Log_File=$(extract_value $SLAVE_STATUS Master_Log_File)
Slave_IO_Running=$(extract_value $SLAVE_STATUS Slave_IO_Running)
Slave_SQL_Running=$(extract_value $SLAVE_STATUS Slave_SQL_Running)
Slave_ERROR=$(extract_value $SLAVE_STATUS Last_Error)
Seconds_Behind_Master=$(extract_value $SLAVE_STATUS Seconds_Behind_Master)

ERROR_COUNT=0
if [[ "$Master_Binlog" != "$Master_Log_File" ]]
then
    ERRORS[$ERROR_COUNT]="master binlog ($Master_Binlog) and Master_Log_File ($Master_Log_File) differ"
    ERROR_COUNT=$(($ERROR_COUNT+1))
fi

if [[ $Seconds_Behind_Master -gt 1000 ]]
then
    ERRORS[$ERROR_COUNT]="The slave is lagging behind of master by $Seconds_Behind_Master seconds"
    ERROR_COUNT=$(($ERROR_COUNT+1))
fi

if [[ "$Slave_IO_Running" == "No" ]]
then
    ERRORS[$ERROR_COUNT]="Replication is stopped"
    ERROR_COUNT=$(($ERROR_COUNT+1))
fi

if [[ "$Slave_SQL_Running" == "No" ]]
then
    ERRORS[$ERROR_COUNT]="Replication (SQL) is stopped"
    ERROR_COUNT=$(($ERROR_COUNT+1))
fi

if [[ $ERROR_COUNT -gt 0 ]]
then
    JSON_ERRORS=$(json_array $ERRORS)
    STATUS="{\"success\": false, \"position_lag\": \"$Seconds_Behind_Master\", \"error_count\": $ERROR_COUNT, \"errors\": $JSON_ERRORS, \"message\": \"$Slave_ERROR\"}"
else
    STATUS="{\"success\": true, \"position_lag\": \"$Seconds_Behind_Master\", \"error_count\": 0}"
fi

send_status $STATUS
