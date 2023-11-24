# Apache ManifoldCF SDK 0.0.2-SNAPSHOT
This is the SDK project of Apache ManifoldCF dedicated to developers that need to extend the platform with new components, connectors or integrations using Maven and Docker. On the other hand this SDK can be extremely useful also for all the developers who want to contribute to the ManifoldCF project.
This project is started with an initial contribution by @OpenPj and @binduwavell.

The SDK will take care of the following tasks:
* Creating the Docker Volumes for the MCF Maven Repo and the MCF installation
* Preparing the Docker Image for executing the build installing Ant and Maven
* Running the container for executing the building process with Ant and then with Maven
* Copying the entire Maven Repo in the Maven target folder in the host machine (locally)

Examples of commands using the main bash script for a typical usage:
* `./run.sh init 2.26 ga` -> start the init process for ManifoldCF 2.26 GA
* `mvn clean install docker:build docker:start` -> build extensions and run everything with Docker locally
* `mvn docker:stop` -> stop all the containers (MCF and PostgreSQL)

Examples of commands for developing and testing MCF itself:
* `./run.sh init 2.22.1 rc` -> start the init process for ManifoldCF 2.22.1 RC
* `./run.sh test` -> execute unit and integration tests in the MCF source bundle
* `./run.sh clean` -> execute ant clean; mvn clean in the MCF source bundle
* `./run.sh purge` -> removes all the Docker Volumes and the MCF init container

# Initializing the local Maven repository using Docker
In order to compile extensions with Maven, the SDK provides an initialization script that will download the source code of ManifoldCF and then build it in the container. At the end of the build process the Maven repository included in the container will be copied in the local folder `target/mcf-maven-repo`. The local Maven repo will be used as the main reference for compiling the extension code.

The initialization command consists of the following arguments:
* MCF version
* MCF distribution: ga for GA release and rc for a Release Candidate

Example for initializing ManifoldCF 2.26 GA release:
* `./run.sh init 2.26 ga`

Example for initializing ManifoldCF 2.27.1 RC release:
* `./run.sh init 2.27.1 rc`

The initialization process will be executed with the following command:
* `/run.sh init 2.21 ga`

# Docker Image, Containers and Volumes
The Docker image created with for creating the ManifoldCF installation and Maven repo is `mcf-sdk-init`.
The Docker container built by the SDK in order to create the installation folder and the Maven repo is `mcf-sdk-init-container`.

The Docker Volumes managed by the SDK are the following:
* `mcf-maven-repo` -> this is the Maven repo created by the initialization process
* `mcf-app-volume` -> this is the installation storage of ManifoldCF


# Building extensions, overlaying and run Docker
A Dockerfile and a Docker Compose file is provided in order to build the ManifoldCF container and for running the instance with its own database, a PostgreSQL container.

The following command will take care of building extensions, run tests and building and running the ManifoldCF container
* `mvn clean install docker:build docker:start`

To stop all the containers:
* `mvn docker:stop`

# Executing tests in the container
For running MCF tests related to the source code bundle:
* `./run.sh test` -> execute unit and integration tests for the related MCF version initialized in the Docker Volumes

