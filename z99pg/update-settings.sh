mkdir -p ${HOME}/z99modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z99passive z99active z99pg 
