USER root

# https://github.com/StatCan/aaw-kubeflow-containers/issues/293
RUN pip3 --no-cache-dir install --quiet \
      'Pillow==9.0.1' \
      'notebook==6.4.1' \
      'PyYAML==5.4.1' \
      'jupyterlab==3.5.3' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

RUN pip3 --no-cache-dir install --quiet \
      'kubeflow-metadata==0.2.0' \
      'kubeflow-pytorchjob==0.1.3' \
      'kubeflow-tfjob==0.1.3' \
      'minio==5.0.10' \
      'joblib==1.2.0' \
      'git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

RUN pip3 --no-cache-dir install --quiet \
      'fire==0.3.1' \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER