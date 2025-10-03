DOCKER_IMAGE_NAME = wasixcc
DTR_DOMAIN = quay.io

build:
	docker build -t ${USER}/${DOCKER_IMAGE_NAME} .

# If you have to configure volumes, do that from here
# configure:

run:
	(docker start ${DOCKER_IMAGE_NAME}) || \
	docker run --name ${DOCKER_IMAGE_NAME} -d ${USER}/${DOCKER_IMAGE_NAME}

console:
	docker run -it \
  -e an_env_var=${HIDDEN_ENV} \
  ${USER}/${DOCKER_IMAGE_NAME} bash

push:
	docker tag ${USER}/${DOCKER_IMAGE_NAME}:latest ${DTR_DOMAIN}/${USER}/${DOCKER_IMAGE_NAME}:latest && \
  docker push ${DTR_DOMAIN}/${USER}/${DOCKER_IMAGE_NAME}:latest

clean:
	docker stop ${DOCKER_IMAGE_NAME}; \
  docker rm ${DOCKER_IMAGE_NAME}; \
  docker rmi ${USER}/${DOCKER_IMAGE_NAME};

.PHONY: run console build push
