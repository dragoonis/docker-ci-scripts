BASE = my-registry.com/myorg
NAME = myapp
TAG = $(TAG)

.PHONY: all build test shell run clean

all: build test

build:
	docker build --pull --force-rm -t ${BASE}/${NAME}:${TAG} .

shell:
	docker run -P --rm -it --name ${NAME} ${BASE}/${NAME}:$(TAG) /bin/sh

run:
	docker run -P --rm --name ${NAME} ${BASE}/${NAME}:$(TAG)

clean:
	docker rmi ${BASE}/${NAME}:$(TAG)
