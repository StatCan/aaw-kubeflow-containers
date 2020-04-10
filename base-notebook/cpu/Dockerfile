# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
FROM jupyter/datascience-notebook
USER root
ENV PATH="/home/jovyan/.local/bin:${PATH}"

RUN pip --no-cache-dir install  --quiet \
      'kfp' \
      'kfp-server-api' \
      'git+https://github.com/kubeflow/fairing@b1065c68f93b13389b19a21a17c8ca3d60fa75b7' \
      'minio'

# Configure container startup
EXPOSE 8888
USER jovyan
COPY start-custom.sh /usr/local/bin/
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
