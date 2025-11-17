#!/bin/bash

# see all listening ports
EXISTING_FRONTENDS=$(ss --tcp --liste --numeric --ipv4 |  grep -Eo '80..' | sort | uniq)
MAJOR=$(echo "${EXISTING_FRONTENDS}" | grep -Eo '..$')

# obtain session token for each
echo "${EXISTING_FRONTENDS}" | grep -v "^$" | while IFS= read -r LINE
do {
echo
NR=$(echo "${LINE}" | grep -Eo '..$')
echo ${NR}

# order of follow ups
echo "
user.login
proxy.get
" | grep -v "^$" | while IFS= read -r STEP
do {

# check minimal version
find api -name ${STEP}.json | sort | while IFS= read -r MINVER 
do {

VER=$(echo "${MINVER}" | grep -Eo "[0-9]+")

[ "${NR}" -lt "${VER}" ] && BODY=${MINVER} && echo "${MINVER}" > /tmp/path.cat && cat "${BODY}" > /tmp/body.json && break

} done

# store session token
echo 'user.login' | grep "${STEP}" > /dev/null
[ "$?" -eq "0" ] && curl --silent \
--request POST \
--header 'Content-Type: application/json-rpc' \
--data "$(jq . /tmp/body.json -c)" \
http://127.0.0.1:${LINE}/api_jsonrpc.php | grep -Eo "([0-9a-f]{32,32})" | tee /tmp/.zabbix.api.${NR}

echo 'proxy.get' | grep "${STEP}" > /dev/null
[ "$?" -eq "0" ] && \
if [ "${LINE}" -lt "8063" ]; then

curl --silent \
--request POST \
--header 'Content-Type: application/json-rpc' \
--data "$(jq . $(cat /tmp/path.cat) -c | sed "s|TOKEN|$(cat /tmp/.zabbix.api.${NR})|")" \
http://127.0.0.1:${LINE}/api_jsonrpc.php

else

echo asdf

fi

} done

} done
echo

