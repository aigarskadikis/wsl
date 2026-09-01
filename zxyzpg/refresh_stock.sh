#!/bin/bash

# exit on any failure
set -e

# print commands
set -o xtrace

# read current directory to automatically understand where is php file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# remove old directory
rm -rf /tmp/zabbix-release-X.y

# make fresh directory
mkdir -p /tmp/zabbix-release-X.y

# generate static session token by using menu "Users" => "API tokens"
SID=$(cat ~/.zabbix-X.y-auth)

# frontend endpoint
JSONRPC=$(cat ~/.zabbix-X.y-url)/api_jsonrpc.php

# download latest X.y branch from official repository of vendor
curl --insecure \
--location \
--output "/tmp/zabbix-release-X.y/X.y.zip" \
"https://git.zabbix.com/rest/api/latest/projects/ZBX/repos/zabbix/archive?at=refs%2Fheads%2Frelease%2FX.y&format=zip"

# unzip
cd "/tmp/zabbix-release-X.y"
unzip "X.y.zip"
rm -rf "/tmp/zabbix-release-X.y/X.y.zip"

# do not print detailed commands
set +o xtrace

# start template import
find /tmp/zabbix-release-X.y/templates -type f -name '*.yaml' | \
while IFS= read -r TEMPLATE
do {
php "$SCRIPT_DIR/delete_missing.php" "$SID" "$JSONRPC" "$TEMPLATE" | \
jq .result | \
grep "true" > /dev/null && echo "OK $TEMPLATE"
# if 'true' not received the print the template name
[[ $? -ne 0 ]] && echo "failed $TEMPLATE"
} done

# print commands
set -o xtrace

# remove working directory
rm -rf "/tmp/zabbix-release-X.y"

