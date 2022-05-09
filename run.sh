#!/bin/sh
mcfversion=$2
mcfdist=$3

echo "Starting Apache ManifoldCF SDK initialization for version $mcfversion"

init() {
	mcfversionInFuction=$1
	echo "Init - 1 = $1"
	mcfdistInFunction=$2
	echo "Init - 2 = $2"
    
    echo "Creating Docker Volume for the ManifoldCF Maven Repository"
    docker volume create --name mcf-maven-repo
    
    echo "Creating Docker Volume for the ManifoldCF Installation..."
    docker volume create --name mcf-app-volume
    
    echo "Building the Docker Container for executing Ant and Maven build..."
	docker build --build-arg MCF_VERSION=$mcfversionInFuction --build-arg MCF_DIST_URL=$mcfdistInFunction src/main/docker -t mcf-sdk-init
	
	echo "Starting the mcf-sdk-build-container for executing the Maven and Ant building process..."
	docker run -it --rm --name mcf-sdk-init-container -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init /bin/bash -c "ant make-core-deps make-deps build; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-api-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-api-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-authority-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-authority-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-combined-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-combined-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-crawler-ui -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-crawler-ui.war
	mvn -B -e -T 1C clean install -DskipTests -DskipITs"
	
	echo "Starting the mcf-sdk-init-container to export the Maven repository in target/mcf-maven-repo..."
	docker run --rm --name mcf-sdk-init-container -itd -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init bash
	
	echo "Copying the ManifoldCF Maven Repo in target/mcf-maven-repo..."
	mkdir target
	docker cp mcf-sdk-init-container:/root/.m2/repository target/mcf-maven-repo
	
	echo "Stopping and removing the existent building container..."
	docker stop mcf-sdk-init-container
	
	#echo "Merging the ManifoldCF Maven Repository with the local Maven Repo"
	#cp -n target/mcf-maven-repo $HOME/.m2
}

test() {
	echo "Starting the mcf-sdk-test-container to execute unit and integration tests"
	docker run -it --rm -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init ant test
}

clean() {
	echo "Starting the mcf-sdk-clean-container to clean the project"
	docker run -it --rm -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init ant clean; mvn clean
}

purge() {
	echo "Removing the ManifoldCF Maven repo and installation volumes"
	docker volume rm mcf-maven-repo
    docker volume rm mcf-app-volume
    docker image rm mcf-sdk-init
}

case "$1" in
  init)
    if [ ! -n "$mcfversion" ]
	then
	    echo "$0 - Error ManifoldCF version is not set. Usage for using ManifoldCF 2.21: $0 init 2.21 ga"
	    exit 1
	else
	    echo "ManifoldCF version is correctly set"
	fi
	if [ ! -n "$mcfdist" ]
	then
	    echo "$0 - Error ManifoldCF release type is not set, it should be ga or rc. Usage for using ManifoldCF 2.21: $0 init 2.21 ga or $0 init 2.21 rc"
	    exit 1
	else
	    echo "ManifoldCF release type is correctly set and now starting Apache ManifoldCF SDK initialization script..."
	fi
	if [ "$mcfdist"=="ga" ];
	mcfdisturl=""
	then
		mcfdisturl="https://dlcdn.apache.org/manifoldcf"
		echo "Building a GA release with artifact base URL: $mcfdisturl"
	else
		mcfdisturl="https://dist.apache.org/repos/dist/dev/manifoldcf"
		echo "Building a RC release with artifact base URL: $mcfdisturl"
	fi
    init $mcfversion $mcfdisturl
    ;;
  clean)
    clean
    ;;
  test)
    test
    ;;
  purge)
    purge
    ;;
  *)
    echo "Usage: $0 {init|clean|test|purge}"
esac