#set( $symbol_dollar = '$' )
@ECHO OFF

IF [%M2_HOME%]==[] (
    SET MVN_EXEC=mvn
)

IF NOT [%M2_HOME%]==[] (
    SET MVN_EXEC=%M2_HOME%\bin\mvn
)

IF [%1]==[] (
    echo "Usage: %0 {init|clean|build_start|start|stop|unittests|integrationtests|test|purge}"
    GOTO END
)

IF %1==build_start (
    CALL :build_start
)

IF %1==build (
	CALL :build
)

IF %1==build_test (
	CALL :build_test
)

IF %1==unittests (
    CALL :unittests
)

IF %1==integrationtests (
	CALL :integrationtests
)

IF %1==start (
	CALL :start
)

IF %1==stop (
	CALL :stop
)

IF %1==test (
	CALL :test
)

IF %1==clean (
	CALL :clean
)

IF %1==purge (
	CALL :purge
)

echo "Usage: %0 {init|clean|build_start|start|stop|unittests|integrationtests|test|purge}"
:END
EXIT /B %ERRORLEVEL%

:build_start
	echo "Building with Maven skipping tests and run Docker containers"
	call %MVN_EXEC% clean install docker:build docker:start -DskipTests -DskipITs
EXIT /B 0
:build
	echo "Building with Maven skipping tests"
	call %MVN_EXEC% clean install -DskipTests -DskipITs
EXIT /B 0
:build_test
	echo "Building with Maven executing tests"
	call %MVN_EXEC% clean install
EXIT /B 0
:unittests
	echo "Executing unit tests"
	call %MVN_EXEC% clean test
EXIT /B 0
:integrationtests
	echo "Executing integration tests"
	call %MVN_EXEC% clean integration-test
EXIT /B 0
:start
	echo "Run ManifoldCF Docker containers"
	call %MVN_EXEC% docker:start
EXIT /B 0
:stop
	echo "Stop ManifoldCF Docker containers"
	call %MVN_EXEC% docker:stop
EXIT /B 0
:test
	echo "Starting the mcf-sdk-test-container to execute unit and integration tests"
	docker run -it --rm -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init ant test
EXIT /B 0
:clean
	echo "Starting the mcf-sdk-clean-container to clean the project"
	docker run -it --rm -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init ant clean; mvn clean
EXIT /B 0
:purge
	echo "Removing the ManifoldCF Maven repo and installation volumes"
	docker volume rm mcf-maven-repo
	docker volume rm mcf-app-volume
	docker image rm mcf-sdk-init
EXIT /B 0


