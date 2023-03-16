# Remove libpdfbox-java due to CVE-2019-0228. See https://github.com/StatCan/aaw-kubeflow-containers/issues/249#issuecomment-834808115 for details.
# Issue opened https://github.com/jupyter/docker-stacks/issues/1299.
# This line of code should be removed once a solution or better alternative is found.
USER root
RUN apt-get update --yes \
    && dpkg -r --force-depends libpdfbox-java \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 --no-cache-dir install --quiet \
      'wheel==0.40.0' \
      'setuptools==67.6.0' \
      'pyjwt==2.6.0' \
      'oauthlib==3.2.2' \
      'nbconvert==7.2.10' \
      'mpmath==1.3.0' \
      'mako==1.2.4' \
      'lxml==4.9.2' \
      'notebook-shim==0.2.2'\
      'jupyter-server==2.4.0' \
      && fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER
      
USER $NB_USER