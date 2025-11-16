#!/bin/bash

COMMIT=release/7.0
DBNAME=z70
# this script is required to create a correct database for the container

cd ~/zabbix
git reset --hard HEAD && \
git clean -fd

git checkout master && \
git pull && \
git switch --detach ${COMMIT} && \
head -9 ChangeLog && \
./bootstrap.sh && \
./configure && \
make dbschema

# ensure service user exists:
docker exec -it pg17ts psql -U postgres -c \
"DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'zabbix') THEN
      CREATE ROLE zabbix WITH LOGIN PASSWORD 'zabbix';
   END IF;
END
\$\$;"

# drop database
docker exec -it pg17ts psql -U postgres -c "DROP DATABASE IF EXISTS $DBNAME;"

# create database and assign to user 'zabbix'
docker exec -it pg17ts psql -U postgres -c "CREATE DATABASE $DBNAME OWNER zabbix;"

cat ~/zabbix/database/postgresql/schema.sql | docker exec -i pg17ts psql -U zabbix -d $DBNAME
cat ~/zabbix/database/postgresql/images.sql | docker exec -i pg17ts psql -U zabbix -d $DBNAME
cat ~/zabbix/database/postgresql/data.sql | docker exec -i pg17ts psql -U zabbix -d $DBNAME

