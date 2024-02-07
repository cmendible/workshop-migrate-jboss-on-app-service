FROM mcr.microsoft.com/devcontainers/java:11

RUN curl -o /usr/bin/slirp4netns -fsSL https://github.com/rootless-containers/slirp4netns/releases/download/v1.1.12/slirp4netns-$(uname -m) \
    && chmod +x /usr/bin/slirp4netns

# postgres CLI & podman
RUN sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
    && apt-get update \
    && apt-get -y install postgresql podman

# Wildfly  (https://github.com/jboss-dockerfiles/wildfly/blob/master/Dockerfile)
ENV WILDFLY_VERSION 24.0.1.Final
ENV JBOSS_HOME /opt/jboss/wildfly
ENV DEPLOYMENT_DIR /workspace/deployments
ENV WILDFLY_SHA1 751e3ff9128a6fbe72016552a9b864f729a710cc
ENV LAUNCH_JBOSS_IN_BACKGROUND true
ENV SETUP_DIR=/setup

RUN mkdir -p ${JBOSS_HOME}
RUN mkdir -p ${DEPLOYMENT_DIR}
RUN mkdir -p ${SETUP_DIR}

RUN wget -O ${SETUP_DIR}/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.24.jar
COPY ./setup ${SETUP_DIR}/

RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION/* $JBOSS_HOME/ \
    && rm -rf wildfly-$WILDFLY_VERSION.tar.gz

RUN cat ${SETUP_DIR}/jboss-cli-docker.cli ${SETUP_DIR}/jboss-cli-commands.cli > ${SETUP_DIR}/config.cli
RUN cat ${SETUP_DIR}/config.cli

RUN $JBOSS_HOME/bin/jboss-cli.sh --echo-command --file=${SETUP_DIR}/config.cli \
    && rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history \
    && chown -R vscode:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}
