#!/bin/bash

# see all listening ports
EXISTING_FRONTENDS=$(ss --tcp --liste --numeric --ipv4 |  grep -Eo '80..' | sort | uniq)
MAJOR=$(echo "${EXISTING_FRONTENDS}" | grep -Eo '..$')

# obtain session token for each
echo "${EXISTING_FRONTENDS}" | grep -v "^$" | while IFS= read -r LINE
do {
echo
echo ${LINE}
NR=$(echo "${LINE}" | grep -Eo '..$')

if [ "${LINE}" -lt "8063" ]; then
TOKEN=$(curl --silent \
--request POST \
--header 'Content-Type: application/json-rpc' \
--data '{
 "jsonrpc": "2.0",
 "method": "user.login",
 "params": {
  "user": "Admin",
  "password": "zabbix"
 },
"id":1
}' http://127.0.0.1:${LINE}/api_jsonrpc.php | grep -Eo "([0-9a-f]{32,32})")

# fetch proxy list
PROXY_LIST="$(curl --silent \
--request POST \
--header 'Content-Type: application/json-rpc' \
--data '{
    "jsonrpc": "2.0",
    "method": "proxy.get",
    "params": {
        "output": "extend"
    },
    "id": 1,
    "auth": "'${TOKEN}'"
}' http://127.0.0.1:${LINE}/api_jsonrpc.php)"

echo "${PROXY_LIST}"

else

# starting with 6.4
TOKEN=$(curl --silent \
--request POST \
--header 'Content-Type: application/json-rpc' \
--data '{
 "jsonrpc": "2.0",
 "method": "user.login",
 "params": {
  "username": "Admin",
  "password": "zabbix"
 },
 "id": 1
}' http://127.0.0.1:${LINE}/api_jsonrpc.php | grep -Eo "([0-9a-f]{32,32})")

PROXY_LIST="$(curl --silent \
--request POST \
--header 'Content-Type: application/json-rpc' \
--header 'Authorization: Bearer '${TOKEN} \
--data '{
    "jsonrpc": "2.0",
    "method": "proxy.get",
    "params": {
        "output": "extend"
    },
    "id": 1
}' http://127.0.0.1:${LINE}/api_jsonrpc.php | jq .result[0].address)"

echo "${PROXY_LIST}" | grep "10.88.3.1${MAJOR}" || \
curl --silent \
--request POST \
--header 'Content-Type: application/json-rpc' \
--header 'Authorization: Bearer '${TOKEN} \
--data '
{"jsonrpc":"2.0","method":"proxy.create","params":{"name":"passive","operating_mode":"1","address":"10.88.3.1'${NR}'","port":"10051"},"id":1}
' http://127.0.0.1:${LINE}/api_jsonrpc.php

fi



} done
echo

