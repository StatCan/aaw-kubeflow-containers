USER root

# https://github.com/StatCan/aaw-kubeflow-containers/issues/293
RUN pip3 --no-cache-dir install --quiet \
      'Pillow==9.4.0' \
      'notebook==6.5.3' \
      'PyYAML==6.0' \
      'jupyterlab==3.6.1' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

RUN pip3 --no-cache-dir install --quiet \
      'kubeflow-pytorchjob==0.1.3' \
      'kubeflow-tfjob==0.1.3' \
      'minio==7.1.13' \
      'joblib==1.2.0' \
      'git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

RUN pip3 --no-cache-dir install --quiet \
      'fire==0.5.0' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

COPY aaw-suspend-server.sh /usr/local/bin
RUN chmod +x /usr/local/bin/aaw-suspend-server.sh
