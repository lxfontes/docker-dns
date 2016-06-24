#!/bin/bash

IMAGE_SOURCE="lxfontes/docker-dns"
LOCAL_CONTAINER="docker-dns"
PORT=5356
LOCAL_DOMAIN=localdev

docker info 2>&1 > /dev/null
if [ $? -ne 0 ]; then
  echo "Please check your docker installation"
  exit 1
fi

echo "Checking for previous install"
docker inspect $LOCAL_CONTAINER 2>&1 > /dev/null
if [ $? -eq 0 ]; then
  echo "Stopping previous install"
  docker stop $LOCAL_CONTAINER

  echo "Deregistering name"
  docker rm $LOCAL_CONTAINER
fi

set -e

echo "Creating resolver configuration (mac)"
if [ ! -d /etc/resolver ]; then
  sudo mkdir /etc/resolver
fi

cat <<EOF | sudo tee /etc/resolver/$LOCAL_DOMAIN 2>&1 > /dev/null
nameserver 127.0.0.1
port $PORT
EOF

docker pull $IMAGE_SOURCE

docker run -d -e LOCAL=$LOCAL_DOMAIN -p $PORT:53/udp -v/var/run/docker.sock:/var/run/docker.sock --restart always --name $LOCAL_CONTAINER $IMAGE_SOURCE

echo "Waiting for container to boot"
while true; do
  STATUS=$(docker inspect -f "{{.State.Running}}" $LOCAL_CONTAINER)
  if [ "$STATUS" == "true" ]; then
    break
  fi
  echo -n "."
  sleep 1
done

echo "All set!"
echo
