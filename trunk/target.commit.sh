#!/bin/bash

docker stop testo; docker rm testo;
docker run --name testo -d zabbix/zabbix-server-pgsql:trunk-alpine

COMMIT=$(docker exec -it testo zabbix_server --version | grep -Eo "Revision \S+" | grep -Eo "\S+$")

docker stop testo; docker rm testo;

#COMMIT=c968b3c

# this script is required to create a correct database for the z99 container

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
docker exec -it pg18ts psql -U postgres -c \
"DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'zabbix') THEN
      CREATE ROLE zabbix WITH LOGIN PASSWORD 'zabbix';
   END IF;
END
\$\$;"

# drop database
docker exec -it pg18ts psql -U postgres -c "DROP DATABASE IF EXISTS z99;"

# create database and assign to user 'zabbix'
docker exec -it pg18ts psql -U postgres -c "CREATE DATABASE z99 OWNER zabbix;"

cat ~/zabbix/database/postgresql/schema.sql | docker exec -i pg18ts psql -U zabbix -d z99
cat ~/zabbix/database/postgresql/images.sql | docker exec -i pg18ts psql -U zabbix -d z99
cat ~/zabbix/database/postgresql/data.sql | docker exec -i pg18ts psql -U zabbix -d z99

cd -
cat ../update.sql | docker exec -i pg18ts psql -U zabbix -d z99
