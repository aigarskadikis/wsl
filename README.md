# wsl
Windows Subsystem for Linux - Run optimal set of containers via Ubuntu via docker not podman

All upcoming examples will use official Docker (from Ubuntu 24). The containers will run in non-root environment.

## Enable official docker monitoring via Zabbix Agent 2 

To enable official docker template with Zabbix agent 2 via Ubuntu 24, need to add service user 'zabbix' to be a part of docker group. this will allow zabbix_agent2 to read /run/docker.sock file.

```
usermod -a -G docker zabbix
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
-v ${HOME}/postgresql/16:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD="zabbix" \
-e POSTGRES_DB="dummy_db" \
-p 7416:5432 \
-d timescale/timescaledb:2.16.1-pg16
```

Run PostgreSQL 17 container

```
mkdir -p ${HOME}/postgresql/17

docker run --name pg17ts2181 -t \
-e PGDATA=/var/lib/postgresql/data/pgdata \
-v ${HOME}/postgresql/17:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD="zabbix" \
-e POSTGRES_DB="dummy_db" \
-p 7417:5432 \
-d timescale/timescaledb:2.18.1-pg17
```
