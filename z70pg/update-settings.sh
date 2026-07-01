mkdir -p ${HOME}/z70modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z70passive z70active z70pg 
