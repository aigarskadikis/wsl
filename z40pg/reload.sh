docker exec -it z40pg zabbix_server -R config_cache_reload
sleep 3
docker exec -it z40prx zabbix_proxy -R config_cache_reload
