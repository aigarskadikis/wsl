docker exec -it pg13ts su - postgres

createuser --pwprompt zabbix

createdb z40 --owner=zabbix

wget https://cdn.zabbix.com/zabbix/sources/oldstable/4.0/zabbix-4.0.50.tar.gz
tar -xvf zabbix-4.0.50.tar.gz
cd zabbix-4.0.50/database/postgresql/
ls
cat schema.sql images.sql data.sql | psql --user=zabbix z40
exit


