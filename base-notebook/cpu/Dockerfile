# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
FROM jupyter/datascience-notebook
USER root
ENV PATH="/home/jovyan/.local/bin:${PATH}"

RUN pip --no-cache-dir install  --quiet \
      'kfp' \
      'kfp-server-api' \
      'git+https://github.com/kubeflow/fairing@b1065c68f93b13389b19a21a17c8ca3d60fa75b7' \
      'minio'

# Added ODBC Support for Dremio
RUN conda install --quiet --yes pyodbc && \
    apt-get update && \
    apt-get install -y alien unixodbc unixodbc-dev && \
    wget http://download.dremio.com/odbc-driver/dremio-odbc-LATEST.x86_64.rpm && \
    alien -i --scripts dremio-odbc-*x86_64.rpm && \
    rm -f dremio-odbc-*x86_64.rpm && \
    rm -rf /var/lib/apt/lists/* && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Need this to connect
ENV DREMIO_DRIVER=/opt/dremio-odbc/lib64/libdrillodbc_sb64.so

# Configure container startup
EXPOSE 8888
USER jovyan
COPY start-custom.sh /usr/local/bin/
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
