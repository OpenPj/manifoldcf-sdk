#set( $symbol_dollar = '$' )
@ECHO OFF

IF [%M2_HOME%]==[] (
    SET MVN_EXEC=mvn
)

IF NOT [%M2_HOME%]==[] (
    SET MVN_EXEC=%M2_HOME%\bin\mvn
)

IF [%1]==[] (
    echo "Usage: %0 {build|clean|start|stop|purge}"
    GOTO END
)

IF %1==build (
    CALL :build
)

IF %1==start (
    CALL :start
)

IF %1==stop (
    CALL :stop
)

IF %1==clean (
    CALL :clean
)

IF %1==purge (
    CALL :purge
)

echo "Usage: %0 {build|clean|start|stop|purge}"
:END
EXIT /B %ERRORLEVEL%

:build
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
EXIT /B 0

:start
	echo "Run ManifoldCF Site Docker container"
	docker run -it -v mcf-site-source:/usr/src/manifoldcf-site -v mcf-site-generated-volume:/usr/src/manifoldcf-site/build/site -t mcf-sdk-site sh
EXIT /B 0

:stop
	echo "Stop ManifoldCF Site Docker container"
	docker stop mcf-sdk-site
EXIT /B 0

:clean
	echo "Starting the mcf-sdk-site to clean the project"
	docker run -it --rm -v mcf-site-source:/usr/src/manifoldcf-site -v mcf-site-generated-volume:/usr/src/manifoldcf-site/build/site -t mcf-sdk-site ant clean
	call %MVN_EXEC% clean
EXIT /B 0

:purge
	echo "Removing the ManifoldCF Site Docker artifacts and volumes"
	docker volume rm mcf-site-source
  	docker volume rm mcf-site-generated-volume
  	docker rm mcf-sdk-site
  	docker image rm mcf-sdk-site
EXIT /B 0