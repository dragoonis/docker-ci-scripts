BASE = my-registry.com/myorg
NAME = myapp

.PHONY: all build test shell run clean

all: build test

build:
	docker build --pull --force-rm -t ${BASE}/${NAME}:local .

php56:
	docker build --pull --force-rm -t ${BASE}/${NAME}:5.6 .

php70:
	docker build --pull --force-rm -t ${BASE}/${NAME}:7.0 -f Dockerfile7 .

shell:
	docker run -P --rm -it --name ${NAME} ${BASE}/${NAME}:local /bin/sh

run:
	docker run -P --rm --name ${NAME} ${BASE}/${NAME}:local

clean:
	docker rmi ${BASE}/${NAME}:local
