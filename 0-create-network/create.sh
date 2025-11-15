sudo docker network create DockerInternalNet \
  --driver bridge \
  --subnet 10.88.0.0/16 \
  --gateway 10.88.0.1

