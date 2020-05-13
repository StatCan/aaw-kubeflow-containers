# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
FROM jupyter/datascience-notebook
USER root
ENV PATH="/home/jovyan/.local/bin:${PATH}"

RUN pip --no-cache-dir install  --quiet \
      'kfp==0.5.1' \
      'kfp-server-api==0.5.0' \
      'kfp-tekton==0.0.1' \
      'kubeflow-fairing==0.7.2' \
      'kubeflow-metadata==0.3.1' \
      'kubeflow-pytorchjob==0.1.3' \
      'kubeflow-tfjob==0.1.3' \
      'minio==5.0.10' \
      'git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985'

# kfp-azure-databricks needs to be run after kfp
RUN pip --no-cache-dir install  --quiet \
      'fire==0.3.1' \
      'git+https://github.com/kubeflow/pipelines@1d86111d8f152d3ed7506ea59cee1bfbc28abbf9#egg=kfp-azure-databricks&subdirectory=samples/contrib/azure-samples/kfp-azure-databricks'

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
