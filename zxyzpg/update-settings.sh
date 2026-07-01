mkdir -p ${HOME}/zXymodules
docker-compose down && \
docker-compose up -d
docker --version && docker stop zXypassive zXyactive zXypg 
