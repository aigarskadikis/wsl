#!/bin/bash

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
docker exec -it pg17ts psql -U postgres -c "DROP DATABASE IF EXISTS trunk;"

# create database and assign to user 'zabbix'
docker exec -it pg17ts psql -U postgres -c "CREATE DATABASE trunk OWNER zabbix;"

