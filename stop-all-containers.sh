# stop backend
echo 'stopping server..'
docker ps | grep zabbix-server | awk '{ print $1 }' | xargs docker stop

echo 'stopping nginx..'
docker ps | grep nginx | awk '{ print $1 }' | xargs docker stop

echo 'stopping proxy..'
docker ps | grep zabbix-proxy | awk '{ print $1 }' | xargs docker stop

echo 'stopping timescaledb..'
docker ps | grep timescaledb | awk '{ print $1 }' | xargs docker stop

echo 'stopping everything else'
docker ps -a -q | xargs docker stop

