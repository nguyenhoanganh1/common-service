#!/usr/bin/env bash
docker build -t myjenkins-blueocean:2.401.3-1 -f Dockerfile.jenkins .

docker run --name jenkins-blueocean --restart=on-failure --detach --network jenkins --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro --volume /var/run/docker.sock:/var/run/docker.sock --publish 8080:8080 --publish 50000:50000 myjenkins-blueocean:2.401.3-1

docker run --name jenkins-blueocean2 --restart=on-failure --detach --network jenkins --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro --volume ./sock:/var/run/docker.sock --publish 8080:8080 --publish 50000:50000 myjenkins-blueocean:2.401.3-1