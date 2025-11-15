# wsl
Windows Subsystem for Linux - Run optimal set of containers via Ubuntu via docker not podman

All upcoming examples will use official Docker (from Ubuntu 24).

## IP Address map

The table indicates patterns how to choose/remember IP for certain components

### DB flavors

| Database      | GUI           | Exposed port | Container                           |
| :------------ | :------------ | :----------- | :---------------------------------- |
| PostgreSQL 13 | 10.88.74.13   | 7413         | timescale/timescaledb:2.15.3-pg13   |
| PostgreSQL 16 | 10.88.74.16   | 7416         | timescale/timescaledb:2.16.1-pg16   |
| PostgreSQL 17 | 10.88.74.17   | 7417         | timescale/timescaledb:2.18.0-pg17   |
| MySQL 8.0     | 10.88.8.0     | 3306         |                                     |
| MariaDB 10.3  | 10.88.10.3    |              |                                     |
| MariaDB 11.4  | 10.88.11.4    |              |                                     |

### Extra services

| Service       | GUI           | Exposed port | Container                           |
| :------------ | :------------ | :----------- | :---------------------------------- |
| LDAP dir      | 10.88.53.27   | 6636         | bgmot42/openldap-server:0.1.1       |
| PHP admin     | 10.88.53.28   | 4433         | osixia/phpldapadmin:0.9.0           |
| Selenium      |               |              |                                     |
| Grafana       |               |              |                                     |

### Zabbix

| Version | GUI         | zabbix-server | passive prx  | active prx  |
| :------ | :---------- | :------------ | :----------- | :---------- |
| 4.0     | 10.88.1.140 | 10.88.2.140   | 10.88.3.140  | 10.88.4.140 |
| 4.2     | 10.88.1.142 | 10.88.2.142   | 10.88.3.142  | 10.88.4.142 |
| 4.4     | 10.88.1.144 | 10.88.2.144   | 10.88.3.144  | 10.88.4.144 |
| 5.0     | 10.88.1.150 | 10.88.2.150   | 10.88.3.150  | 10.88.4.150 |
| 5.2     | 10.88.1.152 | 10.88.2.152   | 10.88.3.152  | 10.88.4.152 |
| 5.4     | 10.88.1.154 | 10.88.2.154   | 10.88.3.154  | 10.88.4.154 |
| 6.0     | 10.88.1.160 | 10.88.2.160   | 10.88.3.160  | 10.88.4.160 |
| 6.2     | 10.88.1.162 | 10.88.2.162   | 10.88.3.162  | 10.88.4.162 |
| 6.4     | 10.88.1.164 | 10.88.2.164   | 10.88.3.164  | 10.88.4.164 |
| 7.0     | 10.88.1.170 | 10.88.2.170   | 10.88.3.170  | 10.88.4.170 |
| 7.2     | 10.88.1.172 | 10.88.2.172   | 10.88.3.172  | 10.88.4.172 |
| 7.4     | 10.88.1.174 | 10.88.2.174   | 10.88.3.174  | 10.88.4.174 |
| 8.0     | 10.88.1.180 | 10.88.2.180   | 10.88.3.180  | 10.88.4.180 |
| trunk   | 10.88.1.111 | 10.88.2.111   | 10.88.3.111  | 10.88.4.111 |

It's possible to substitute a version number in docker-compose file with:

```
grep '7.0' docker-compose.yaml
grep '70' docker-compose.yaml
sed 's|7.4.5|7.0.21|' docker-compose.yaml
sed 's|7.4|7.0|' docker-compose.yaml
sed 's|74|70|' docker-compose.yaml
```


## Allow user 'user' to use sudo without password

```
echo "user ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/011_user-nopasswd
```

## Allow user 'user' to use docker at full

```
sudo usermod -a -G docker user
```

## Install docker daemon (Ubuntu 24, Debina 11, Debian 12)

Use

```
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest \
  | grep tag_name | cut -d '"' -f 4)

sudo curl -L "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

## Enable official docker monitoring via Zabbix Agent 2 

To enable official docker template with Zabbix agent 2 via Ubuntu 24, need to add service user 'zabbix' to be a part of docker group. this will allow zabbix_agent2 to read /run/docker.sock file.

```
sudo usermod -a -G docker zabbix
```

## Create a docker internal network

```
docker network create DockerInternalNet \
  --driver bridge \
  --subnet 10.88.0.0/16 \
  --gateway 10.88.0.1
```

## Create PostgreSQL server via docker

Set a home for data directory

```
mkdir -p ${HOME}/postgresql/16
```

Run PostgreSQL 16 container

```
docker run --name pg16ts2161 -t \
-e PGDATA=/var/lib/postgresql/data/pgdata \
--restart unless-stopped \
--net DockerInternalNet --ip 10.88.74.16 \
-v ${HOME}/postgresql/16:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD="zabbix" \
-e POSTGRES_DB="dummy_db" \
-p 7416:5432 \
-d timescale/timescaledb:2.16.1-pg16
```

## Create DB user

To create DB user 'zabbix' with password 'zabbix', authenticate into a running container

```
docker exec -it  pg16ts2161 su - postgres
```

Create user. The prompt will ask for input. Write 'zabbix' to be password

```
createuser --pwprompt zabbix
```

Exit container

```
exit
```

## Create Zabbix 7.0 database

```
docker exec -it  pg16ts2161 su - postgres
wget https://cdn.zabbix.com/zabbix/sources/stable/7.0/zabbix-7.0.21.tar.gz
tar -xvf zabbix-7.0.21.tar.gz
cd zabbix-7.0.21/database/postgresql/
ls
cat schema.sql images.sql data.sql | psql --user=zabbix z70
exit
```

## Zabbix 7.0 backend

```
docker pull zabbix/zabbix-server-pgsql:ol-7.0.21 && \
docker stop z70pg ; docker rm z70pg ; docker run --name z70pg \
--net DockerInternalNet --ip 10.88.2.70 \
-e TZ="Europe/Riga" \
-e DB_SERVER_HOST="10.88.74.16" \
-e DB_SERVER_PORT="5432" \
-e POSTGRES_DB="z70" \
-e POSTGRES_USER="zabbix" \
-e POSTGRES_PASSWORD="zabbix" \
-e ZBX_ALLOWUNSUPPORTEDDBVERSIONS=1 \
-p 17051:10051 \
--restart unless-stopped \
-d zabbix/zabbix-server-pgsql:ol-7.0.21
```

## Zabbix 7.0 frontend

```
docker pull zabbix/zabbix-web-nginx-pgsql:ol-7.0.21 && \
docker stop z70web ; docker rm z70web ; docker run --name z70web \
--net DockerInternalNet --ip 10.88.3.70 \
--restart unless-stopped \
-e DB_SERVER_HOST="10.88.74.16" \
-e DB_SERVER_PORT="5432" \
-e POSTGRES_DB="z70" \
-e POSTGRES_USER="zabbix" \
-e POSTGRES_PASSWORD="zabbix" \
-e ZBX_SERVER_HOST="10.88.2.70" \
-e ZBX_SERVER_PORT="10051" \
-e PHP_TZ="Europe/Riga" \
-p 8070:8080 \
-d zabbix/zabbix-web-nginx-pgsql:ol-7.0.21
```

## Appendix

### PostgreSQL 17 container

```
mkdir -p ${HOME}/postgresql/17

docker run --name pg17ts2181 -t \
-e PGDATA=/var/lib/postgresql/data/pgdata \
-v ${HOME}/postgresql/17:/var/lib/postgresql/data \
--net DockerInternalNet --ip 10.88.74.17 \
-e POSTGRES_PASSWORD="zabbix" \
-e POSTGRES_DB="dummy_db" \
-p 7417:5432 \
-d timescale/timescaledb:2.18.1-pg17
```
