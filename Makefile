SNAPSHOT=arcgis-experience-builder-beta2
PORT=3001

all:	${SNAPSHOT} widgets build

${SNAPSHOT}: ArcGIS\ Experience\ Builder\ Beta2.zip
	unzip $@

widgets:
	cp -r ${SNAPSHOT}/client/your-extensions extensions

build:	Dockerfile
	docker build -t exb .

run:
	docker run -it --rm -p 3001:${PORT} -v ${PWD}/extensions:/home/node/extensions --name=exb exb

daemon:
	docker run -d --restart=always -p 3001:${PORT} -v ${PWD}/extensions:/home/node/extensions --name=exb exb

exec:
	docker exec -it exb bash

clean:
	docker stop exb
	docker rm exb


