#!/bin/bash
cd
git clone --depth 1 https://git.zabbix.com/scm/zbx/zabbix.git
cd zabbix
git fetch --unshallow
git fetch --tags

