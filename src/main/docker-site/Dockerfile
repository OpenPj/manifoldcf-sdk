FROM alpine:3.15.11

ARG ANT_VERSION=1.9.16
ARG MCF_SOURCE_SITE_DIR=/usr/src/manifoldcf-site

RUN apk update \
	&& apk upgrade \
	&& apk --update add openjdk8 \
	&& apk --update add subversion

#Installing Apache Ant 1.9.x
RUN mkdir -p /opt/ant/ \
    && wget http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz -P /opt/ant \
	&& tar -xvzf /opt/ant/apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ant/ \
	&& rm -f /opt/ant/apache-ant-${ANT_VERSION}-bin.tar.gz
	
ENV ANT_HOME=/opt/ant/apache-ant-${ANT_VERSION}
ENV ANT_OPTS="-Xms256M -Xmx512M"
ENV PATH="${PATH}:${HOME}/bin:${ANT_HOME}/bin"

RUN apk add --no-cache python2 && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache

WORKDIR ${MCF_SOURCE_SITE_DIR}

