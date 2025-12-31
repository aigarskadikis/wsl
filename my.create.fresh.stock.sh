#!/bin/bash

# zabbix version to create
VERSION=$1

[ -z "${VERSION}" ] && echo "second argument must be version of Zabbix" && exit 1

# which version of PostgreSQL to use
MY=$2

# if second argument is empty the set MySQL version 8.0
[ -z "${MY}" ] && MY=80

# formulate a desired DB name. for example if version is '7.4.5' then DB name will be 'z74'
DBNAME=$(echo ${VERSION} | sed 's|\.||g' | grep -Eo '^..' | sed 's|^|z|')

# check if DB is running
ALL_CONTAINERS_STATE="$(docker ps --all --no-trunc --format {{.Names}}.{{.State}})"

echo "${ALL_CONTAINERS_STATE}" | grep "my${MY}.running" || \
docker-compose --project-directory ./my${MY} up --detach || exit 1

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

# create user
docker exec -it my${MY} mysql -uroot -pzabbix -e "CREATE USER IF NOT EXISTS 'zabbix'@'%';"

# reset password
docker exec -it my${MY} mysql -uroot -pzabbix -e "ALTER USER 'zabbix'@'%' IDENTIFIED BY 'password';"

# drop database if it already exist
docker exec -it my${MY} mysql -uroot -pzabbix -e "DROP DATABASE IF EXISTS $DBNAME;"

# create database and assign to user 'zabbix'
docker exec -it my${MY} mysql -uroot -pzabbix -e "CREATE DATABASE $DBNAME CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"

cat ~/zabbix/database/mysql/schema.sql | docker exec -i my${MY} mysql -uroot -pzabbix $DBNAME
cat ~/zabbix/database/mysql/images.sql | docker exec -i my${MY} mysql -uroot -pzabbix $DBNAME
cat ~/zabbix/database/mysql/data.sql | docker exec -i my${MY} mysql -uroot -pzabbix $DBNAME

DBVERSION=$(echo "
SELECT mandatory FROM dbversion;
" | \
docker exec -i my${MY} mysql -sN --batch --user=root --password=zabbix --database=$DBNAME
)

# patches/productivity
cd -

find patches -maxdepth 1 -type f -name '*.sql' | while IFS= read -r SQLCOMMAND
do {
FILE=$(echo $SQLCOMMAND | grep -Eo '[0-9]+')
echo "${SQLCOMMAND}" | grep "${DBVERSION}"
if [ "$?" -eq "0" ]; then
cat "${SQLCOMMAND}"
cat "${SQLCOMMAND}" | docker exec -i my${MY} mysql -sN --batch --user=root --password=zabbix --database=$DBNAME

fi

} done

