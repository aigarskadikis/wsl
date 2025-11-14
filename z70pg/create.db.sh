docker exec -it pg16ts su - postgres
wget https://cdn.zabbix.com/zabbix/sources/stable/7.0/zabbix-7.0.21.tar.gz
tar -xvf zabbix-7.0.21.tar.gz
cd zabbix-7.0.21/database/postgresql/
ls
cat schema.sql images.sql data.sql | psql --user=zabbix z70
exit
