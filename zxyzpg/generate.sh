#!/bin/bash


VERSION=$1

DB=$2

# set default PostgreSQL version if not specified
[ -z "${DB}" ] && DB=17

MAJOR=$(echo ${VERSION} | sed 's|\.||g' | grep -Eo '^..')

echo "${VERSION}" | grep master && MAJOR=99

# see if such version exist
cd ~/zabbix && \
git checkout master

git pull

git fetch --tags
git checkout ${VERSION} || exit 1

git reset --hard HEAD && \
git clean -fd

head -10 ~/zabbix/ChangeLog

# go back to previous directory
cd -

echo "${VERSION}" | grep master
if [ "$?" -eq "0" ]; then
# this is master

mkdir -p ../z${MAJOR}pg && \
cat docker-compose.yml | \
sed "s|Xy|${MAJOR}|g;s|X.Y.Z|trunk|g;s|DBV|${DB}|" | \
tee ../z${MAJOR}pg/docker-compose.yml

else
# this is not master

mkdir -p ../z${MAJOR}pg && \
cat docker-compose.yml | \
sed "s|Xy|${MAJOR}|g;s|X.Y.Z|${VERSION}|g;s|DBV|${DB}|" | \
tee ../z${MAJOR}pg/docker-compose.yml

fi

cat update-settings.sh | tee ../z${MAJOR}pg/update-settings.sh
chmod +x ../z${MAJOR}pg/update-settings.sh

cat stop.sh | tee ../z${MAJOR}pg/stop.sh
chmod +x ../z${MAJOR}pg/stop.sh

#cd ..
#./git.create.fresh.stock.sh ${DB} ${VERSION}
