mkdir -p ${HOME}/z80modules
docker-compose down && \
docker-compose up -d
docker --version && docker stop z80passive z80active 
#docker --version && docker stop z80passive z80active z80pg 
