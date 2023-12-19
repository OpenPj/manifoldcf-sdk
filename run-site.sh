#!/bin/sh

build() {
	echo "Starting Apache ManifoldCF SDK initialization for generating website contents"
    
  echo "Creating Docker Volume for the ManifoldCF Site Source"
  docker volume create --name mcf-site-source
    
  echo "Creating Docker Volume for the ManifoldCF Website"
  docker volume create --name mcf-site-generated-volume
    
  echo "Building the Docker Container for generating website contents"
	docker build src/main/docker-site -t mcf-sdk-site
	
	echo "Starting the mcf-sdk-site to export generated contents in target/mcf-site-generated ..."
	docker run --name mcf-sdk-site -it -v mcf-site-source:/usr/src/manifoldcf-site -v mcf-site-generated-volume:/usr/src/manifoldcf-site/build/site -t mcf-sdk-site sh -c "
	svn co https\:\/\/svn.apache.org/repos/asf/manifoldcf/site/trunk .; \
	ant make-core-deps; \
	ant build"

	echo "Copying the ManifoldCF generated site in target/mcf-site-generated..."
	mkdir -p target/build/site
	docker cp mcf-sdk-site:/usr/src/manifoldcf-site/build/site target/build
	
	echo "Stopping and removing the existent building container..."
	docker stop mcf-sdk-site

}

start() {
	echo "Run ManifoldCF Site Docker container"
	docker run -it -v mcf-site-source:/usr/src/manifoldcf-site -v mcf-site-generated-volume:/usr/src/manifoldcf-site/build/site -t mcf-sdk-site sh
}

stop() {
	echo "Stop ManifoldCF Site Docker container"
	docker stop mcf-sdk-site
}

clean() {
	echo "Starting the mcf-sdk-site to clean the project"
	docker run -it --rm -v mcf-site-source:/usr/src/manifoldcf-site -v mcf-site-generated-volume:/usr/src/manifoldcf-site/build/site -t mcf-sdk-site ant clean
	mvn clean
}

purge() {
	echo "Removing the ManifoldCF Site Docker artifacts and volumes"
	docker volume rm mcf-site-source
  docker volume rm mcf-site-generated-volume
  docker rm mcf-sdk-site
  docker image rm mcf-sdk-site
}

case "$1" in
  build)
    build
    ;;
	start)
		start
		;;
	stop)
		stop
		;;
	clean)
		clean
		;;
  purge)
    purge
    ;;
  *)
    echo "Usage: $0 {build|clean|start|stop|purge}"
esac