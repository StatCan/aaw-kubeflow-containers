# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
FROM jupyter/datascience-notebook
USER root
ENV PATH="/home/jovyan/.local/bin:${PATH}"

RUN pip --no-cache-dir install  --quiet \
      'kfp' \
      'kfp-server-api' \
      'git+https://github.com/kubeflow/fairing@8b08bf7d2703c97901efe8a80717eeccb1133194' \
      'minio'

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["sh","-c", "jupyter notebook --notebook-dir=/home/${NB_USER} --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX} --NotebookApp.default_url='/lab'"]
