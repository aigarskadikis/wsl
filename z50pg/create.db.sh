docker exec -it pg13ts su - postgres

createuser --pwprompt zabbix

createdb z50 --owner=zabbix

wget https://cdn.zabbix.com/zabbix/sources/oldstable/5.0/zabbix-5.0.47.tar.gz
tar -xvf zabbix-5.0.47.tar.gz
cd zabbix-5.0.47/database/postgresql/
ls
cat schema.sql images.sql data.sql | psql --user=zabbix z50
exit
