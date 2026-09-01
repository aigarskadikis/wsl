mkdir -p ${HOME}/z50modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z50passive z50active z50pg 
