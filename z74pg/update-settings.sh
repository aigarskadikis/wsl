mkdir -p ${HOME}/z74modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z74passive z74active z74pg 
