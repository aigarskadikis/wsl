mkdir -p ${HOME}/z60modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z60passive z60active z60pg 
