#!/bin/bash


DB=$1
VERSION=$2
MAJOR=$(echo ${VERSION} | sed 's|\.||g' | grep -Eo '^..')

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

mkdir -p ../z${MAJOR}pg && \
cat docker-compose.yml | \
sed "s|Xy|${MAJOR}|g;s|X.Y.Z|${VERSION}|g;s|DBV|${DB}|" | \
tee ../z${MAJOR}pg/docker-compose.yml

cat update-settings.sh | tee ../z${MAJOR}pg/update-settings.sh
chmod +x ../z${MAJOR}pg/update-settings.sh

cd ..
./git.create.fresh.stock.sh ${DB} ${VERSION}
