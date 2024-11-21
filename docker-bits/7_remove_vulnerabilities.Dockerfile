# Remove libpdfbox-java due to CVE-2019-0228. See https://github.com/StatCan/aaw-kubeflow-containers/issues/249#issuecomment-834808115 for details.
# Issue opened https://github.com/jupyter/docker-stacks/issues/1299.
# This line of code should be removed once a solution or better alternative is found.
USER root
RUN apt-get update --yes \
    && dpkg -r --force-depends libpdfbox-java \
    && rm -rf /var/lib/apt/lists/*

# Forcibly upgrade packages to patch vulnerabilities
# See https://github.com/StatCan/aaw-private/issues/58#issuecomment-1471863092 for more details.
RUN pip3 --no-cache-dir install --quiet \
      'wheel==0.40.0' \
      'setuptools==67.6.0' \
      'pyjwt==2.6.0' \
      'oauthlib==3.2.2' \
      'mpmath==1.3.0' \
      'lxml==4.9.2' \
      'pyarrow==14.0.1' \
      'cryptography==41.0.6' \
      && fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

USER $NB_USER

ARG JACKSON_URL=https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.9.5/jackson-databind-2.9.5.jar
# ARG JACKSON_SHA=3490508379d065fe3fcb80042b62f630f7588606

RUN mvn -v

USER root
RUN wget -q "${JACKSON_URL}" -O /tmp/jackson-databind.jar \
    && echo "jackson-databind: downloaded" \
    && sudo mv /tmp/jackson-databind.jar /usr/local/lib/jackson-databind.jar
ENV CLASSPATH="/usr/local/lib/jackson-databind.jar:${CLASSPATH}"

run echo $CLASSPATH

ENV MAVEN_VERSION=3.9.5 \
    MAVEN_HOME=/usr/share/maven \
    PATH=$MAVEN_HOME/bin:$PATH

# Install Maven
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /usr/share && \
    ln -s /usr/share/apache-maven-${MAVEN_VERSION} $MAVEN_HOME && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Verify Maven installation
RUN mvn --version