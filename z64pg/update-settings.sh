mkdir -p ${HOME}/z64modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z64passive z64active z64pg 
