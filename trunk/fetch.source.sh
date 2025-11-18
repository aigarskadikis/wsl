#!/bin/bash
cd
git clone --depth 1 https://git.zabbix.com/scm/zbx/zabbix.git
cd zabbix
git fetch --unshallow
git fetch --tags
sudo apt -y install lz4
tar --create --verbose --use-compress-program='lz4' --file=${HOME}/source-zabbix.tar.lz4 ${HOME}/zabbix
