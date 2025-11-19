#!/bin/bash

PG=17
DBNAME=z72
DBVERSION=$(echo "
SELECT mandatory FROM dbversion;
" | \
docker exec -i pg${PG}ts psql --tuples-only --no-align -U zabbix -d $DBNAME
)

echo ${DBVERSION}

find patches -maxdepth 1 -type f -name '*.sql' | while IFS= read -r SQLCOMMAND
do {
FILE=$(echo $SQLCOMMAND | grep -Eo '[0-9]+')
echo "${SQLCOMMAND}" | grep "${DBVERSION}"
if [ "$?" -eq "0" ]; then
cat "${SQLCOMMAND}"
cat "${SQLCOMMAND}" | docker exec -i pg${PG}ts psql -U zabbix -d $DBNAME

fi

} done

