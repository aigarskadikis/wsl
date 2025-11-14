docker exec -it pg17ts su - postgres

createuser --pwprompt zabbix

createdb z74 -O zabbix

wget https://cdn.zabbix.com/zabbix/sources/stable/7.4/zabbix-7.4.5.tar.gz
tar -xvf zabbix-7.4.5.tar.gz
cd zabbix-7.4.5/database/postgresql/
ls
cat schema.sql images.sql data.sql | psql --user=zabbix z74
exit
