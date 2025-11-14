# wsl
Windows Subsystem for Linux - Run optimal set of containers via Ubuntu via docker not podman

All upcoming examples will use official Docker (from Ubuntu 24). The containers will run in non-root environment.

## IP Address map

The table indicates patterns how to choose/remember IP for certain components

| Version | GUI           | zabbix-server | passive prx  | active prx  |
| :------ | :------------ | :------------ | :----------- | :---------- |
| 4.0     | 10.88.1.140   | 10.88.2.140   | 10.88.3.140  | 10.88.4.140 |
| 4.2     | 10.88.1.142   | 10.88.2.142   | 10.88.3.142  | 10.88.4.142 |
| 4.4     | 10.88.1.144   | 10.88.2.144   | 10.88.3.144  | 10.88.4.144 |
| 5.0     | 10.88.1.150   | 10.88.2.150   | 10.88.3.150  | 10.88.4.150 |


## Allow user 'user' to use sudo without password

```
echo "user ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/011_user-nopasswd
```

## Allow user 'user' to use docker at full

```
sudo usermod -a -G docker user
```

## Install docker daemon

Use

```
sudo apt -y install docker-compose
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
