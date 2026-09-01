mkdir -p ${HOME}/z72modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z72passive z72active z72pg 
