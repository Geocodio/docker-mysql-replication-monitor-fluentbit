#!/bin/bash
## Based on original script by Joel Chaney, joel.chaney@mongoosemetrics.com, 2012-02-03

SLAVE_STATUS=/tmp/sstatus

SLAVE="mysql -u $MYSQL_USERNAME -p\"'$MYSQL_PASSWORD'\" -h $MYSQL_HOSTNAME"

$SLAVE -e 'SHOW SLAVE STATUS\G' > $SLAVE_STATUS

function extract_value {
    FILENAME=$1
    VAR=$2
    grep -w $VAR $FILENAME | awk '{print $2}'
}

function json_array {
    OUTPUT="["
    while [ $# -gt 0 ]; do
        x=${1//\\/\\\\}
        OUTPUT="${OUTPUT}\"${x//\"/\\\"}\""
        [ $# -gt 1 ] && OUTPUT="${OUTPUT}, "
        shift
    done
    OUTPUT="${OUTPUT}]"
}

Master_Binlog=$(extract_value $SLAVE_STATUS Master_Log_File )
Master_Position=$(extract_value $SLAVE_STATUS Read_Master_Log_Pos )
Master_Host=$(extract_value $SLAVE_STATUS Master_Host)
Master_Port=$(extract_value $SLAVE_STATUS Master_Port)
Master_Log_File=$(extract_value $SLAVE_STATUS Master_Log_File)
Read_Master_Log_Pos=$(extract_value $SLAVE_STATUS Read_Master_Log_Pos)
Slave_IO_Running=$(extract_value $SLAVE_STATUS Slave_IO_Running)
Slave_SQL_Running=$(extract_value $SLAVE_STATUS Slave_SQL_Running)
Slave_ERROR=$(extract_value $SLAVE_STATUS Last_Error)

ERROR_COUNT=0
if [[ "$Master_Binlog" != "$Master_Log_File" ]]
then
    ERRORS[$ERROR_COUNT]="master binlog ($Master_Binlog) and Master_Log_File         ($Master_Log_File) differ"
    ERROR_COUNT=$(($ERROR_COUNT+1))
fi

POS_DIFFERENCE=$(echo ${Master_Position}-${Read_Master_Log_Pos}|bc)

if [[ $POS_DIFFERENCE -gt 1000 ]]
then
    ERRORS[$ERROR_COUNT]="The slave is lagging behind of $POS_DIFFERENCE"
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
  if [[ check_alert_lock == 0 ]]
  then
    STATUS='{"success": false, "error_count": $ERROR_COUNT, "errors": $JSON_ERRORS, "message": "$Slave_ERROR"}'
  fi
else
    STATUS='{"success": true}'
fi

echo $STATUS
echo $STATUS | nc fluentbit 5170
