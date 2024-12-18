# Harden rstudio-server
RUN mkdir -p /etc/rstudio && \
    echo "www-frame-origin=none" >> /etc/rstudio/rserver.conf && \
    echo "www-enable-origin-check=1" >> /etc/rstudio/rserver.conf && \
    echo "www-same-site=lax" >> /etc/rstudio/rserver.conf && \
    echo "restrict-directory-view=1" >> /etc/rstudio/rsession.conf && \
    # Sets the default working dir
    echo "session-default-working-dir=/home/jovyan/workspace" >> /etc/rstudio/rsession.conf && \
    echo "session-default-new-project-dir=/home/jovyan/workspace" >> /etc/rstudio/rsession.conf && \
    # https://github.com/rstudio/rstudio/issues/14060
    echo "rsession-ld-library-path=/opt/conda/lib" >> /etc/rstudio/rserver.conf 

ENV PATH=$PATH:/usr/lib/rstudio-server/bin

# Install some default R packages
RUN mamba install --quiet --yes \
      'r-arrow' \
      'r-aws.s3' \
      'r-catools' \
      'r-e1071' \
      'r-hdf5r' \
      'r-markdown' \
      'r-sparklyr' \
      'r-odbc' \
      'r-renv' \
      'r-rodbc' \
      'r-sf' \
      'r-tidyverse' \
    && \
    clean-layer.sh && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN python3 -m pip install \
    'jupyter-rsession-proxy==2.2.0' \
    'jupyter-server-proxy==4.2.0' && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# ENV SPARK_VERSION=3.5

# If spark_version is not set, latest Spark will be installed
ARG spark_version
ARG hadoop_version="3"
# If scala_version is not set, Spark without Scala will be installed
ARG scala_version
# URL to use for Spark downloads
# You need to use https://archive.apache.org/dist/spark/ website if you want to download old Spark versions
# But it seems to be slower, that's why we use the recommended site for download
ARG spark_download_url="https://dlcdn.apache.org/spark/"

ENV SPARK_HOME=/usr/local/spark
ENV PATH="${PATH}:${SPARK_HOME}/bin"
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info"

# RSpark config
ENV R_LIBS_USER="${SPARK_HOME}/R/lib"
RUN fix-permissions "${R_LIBS_USER}"

COPY setup_spark.py /opt/setup-scripts/

# Setup Spark
RUN /opt/setup-scripts/setup_spark.py \
    --spark-version="${spark_version}" \
    --hadoop-version="${hadoop_version}" \
    --scala-version="${scala_version}" \
    --spark-download-url="${spark_download_url}"

# # Install sparklyr
# RUN apt-get update && \
#     apt install -y --no-install-recommends libxml2-dev libcurl4-openssl-dev && \
#     Rscript -e "library(sparklyr); spark_install(version = ${SPARK_VERSION})"

# If using the docker bit in other Dockerfiles, this must get written over in a later layer
ENV DEFAULT_JUPYTER_URL="/rstudio"
ENV GIT_EXAMPLE_NOTEBOOKS=https://gitlab.k8s.cloud.statcan.ca/business-transformation/aaw/aaw-contrib-r-notebooks.git
