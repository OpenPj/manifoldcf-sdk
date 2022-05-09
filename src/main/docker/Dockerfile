FROM maven:3.8.5-jdk-8

ARG MCF_VERSION=2.21
ARG MCF_SOURCE_DIR=/usr/src/manifoldcf

ARG ANT_VERSION=1.10.12
ARG ANT_HOME=/opt/ant
ARG MCF_DIST_URL

RUN apt-get update && apt-get install -y --no-install-recommends wget openjfx 

RUN wget --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512 \
    && echo "$(cat apache-ant-${ANT_VERSION}-bin.tar.gz.sha512) apache-ant-${ANT_VERSION}-bin.tar.gz" | sha512sum -c \
    && tar -zvxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ \
    && ln -s /opt/apache-ant-${ANT_VERSION} /opt/ant \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz.sha512

RUN update-alternatives --install "/usr/bin/ant" "ant" "/opt/ant/bin/ant" 1 && \
    update-alternatives --set "ant" "/opt/ant/bin/ant"

#RUN wget --no-check-certificate https://dlcdn.apache.org/manifoldcf/apache-manifoldcf-${MCF_VERSION}/apache-manifoldcf-${MCF_VERSION}-src.tar.gz && \
RUN wget ${MCF_DIST_URL}/apache-manifoldcf-${MCF_VERSION}/apache-manifoldcf-${MCF_VERSION}-src.tar.gz && \
    tar -xzvf apache-manifoldcf-${MCF_VERSION}-src.tar.gz && \
    cp -R apache-manifoldcf-${MCF_VERSION} ${MCF_SOURCE_DIR} && \
    rm apache-manifoldcf-${MCF_VERSION}-src.tar.gz

WORKDIR ${MCF_SOURCE_DIR}