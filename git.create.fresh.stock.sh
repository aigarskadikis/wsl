#!/bin/bash

# zabbix version to create
VERSION=$1

[ -z "${VERSION}" ] && echo "second argument must be version of Zabbix" && exit 1

# which version of PostgreSQL to use
PG=$2

# if second argument is empty the set PostgreSQL version 17
[ -z "${PG}" ] && PG=18

# formulate a desired DB name. for example if version is '7.4.5' then DB name will be 'z74'
DBNAME=$(echo ${VERSION} | sed 's|\.||g' | grep -Eo '^..' | sed 's|^|z|')

# check if DB is running
ALL_CONTAINERS_STATE="$(docker ps --all --no-trunc --format {{.Names}}.{{.State}})"

echo "${ALL_CONTAINERS_STATE}" | grep "pg${PG}ts.running" || \
docker-compose --project-directory ./pg${PG} up --detach || exit 1

# switch to version
cd ~/zabbix && \
git fetch --tags && \
git checkout ${VERSION} && \
git reset --hard HEAD && \
git clean -fd && \
head ChangeLog

# prepare
./bootstrap.sh && \
./configure && \
make dbschema

# ensure a dedicated PostgreSQL user 'zabbix' exists:
docker exec -it pg${PG}ts psql -U postgres -c \
"DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'zabbix') THEN
      CREATE ROLE zabbix WITH LOGIN PASSWORD 'zabbix';
   END IF;
END
\$\$;"

# drop database if it already exist
docker exec -it pg${PG}ts psql -U postgres -c "DROP DATABASE IF EXISTS $DBNAME;"

# create database and assign to user 'zabbix'
docker exec -it pg${PG}ts psql -U postgres -c "CREATE DATABASE $DBNAME OWNER zabbix;"

cat ~/zabbix/database/postgresql/schema.sql | docker exec -i pg${PG}ts psql -U zabbix -d $DBNAME
cat ~/zabbix/database/postgresql/images.sql | docker exec -i pg${PG}ts psql -U zabbix -d $DBNAME
cat ~/zabbix/database/postgresql/data.sql | docker exec -i pg${PG}ts psql -U zabbix -d $DBNAME

DBVERSION=$(echo "
SELECT mandatory FROM dbversion;
" | \
docker exec -i pg${PG}ts psql --tuples-only --no-align -U zabbix -d $DBNAME
)

# patches/productivity
cd -

find patches -maxdepth 1 -type f -name '*.sql' | while IFS= read -r SQLCOMMAND
do {
FILE=$(echo $SQLCOMMAND | grep -Eo '[0-9]+')
echo "${SQLCOMMAND}" | grep "${DBVERSION}"
if [ "$?" -eq "0" ]; then
cat "${SQLCOMMAND}"
cat "${SQLCOMMAND}" | docker exec -i pg${PG}ts psql -U zabbix -d $DBNAME

fi

} done

