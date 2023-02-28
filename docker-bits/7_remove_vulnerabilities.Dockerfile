# Remove libpdfbox-java due to CVE-2019-0228. See https://github.com/StatCan/aaw-kubeflow-containers/issues/249#issuecomment-834808115 for details.
# Issue opened https://github.com/jupyter/docker-stacks/issues/1299.
# This line of code should be removed once a solution or better alternative is found.
USER root
RUN apt-get update --yes \
    && dpkg -r --force-depends libpdfbox-java \
    && rm -rf /var/lib/apt/lists/*

USER $NB_USER
#updates package to fix CVE-2023-0286 https://github.com/StatCan/daaas-private/issues/57
RUN conda install --yes --quiet --force-reinstall -c conda-forge pyopenssl==23.0.0