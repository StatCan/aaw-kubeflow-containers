# Rocker/geospatial is tagged by R version number.  They are not clear on whether they'll change those tagged
# images for hotfixes, so always pin tag and digest to prevent unexpected upstream changes

FROM rocker/geospatial:4.2.1@sha256:5caca36b8962233f8636540b7c349d3f493f09e864b6e278cb46946ccf60d4d2

# For compatibility with docker stacks
ARG HOME=/home/$NB_USER
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

ENV NB_USER="${NB_USER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    CONDA_DIR=/opt/conda \
    PATH=$PATH:/opt/conda/bin \
    NB_USER="jovyan" \
    HOME="/home/${NB_USER}"

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

#Fix-permissions
COPY remote-desktop/fix-permissions /usr/bin/fix-permissions
#clean up
COPY clean-layer.sh /usr/bin/clean-layer.sh

RUN chmod u+x /usr/bin/fix-permissions \
    && chmod +x /usr/bin/clean-layer.sh

RUN apt-get update --yes \
    && apt-get install --yes python3-pip tini language-pack-fr \
    && rm -rf /var/lib/apt/lists/*

RUN /rocker_scripts/install_shiny_server.sh \
    && pip3 install jupyter \
    && rm -rf /var/lib/apt/lists/* 

# Users should install R packages in their home directory
RUN chmod 555 /usr/local/lib/R /usr/local/lib/R/site-library/


# ARG CONDA_VERSION=py38_4.10.3
# ARG CONDA_MD5=14da4a9a44b337f7ccb8363537f65b9c
ARG PYTHON_VERSION=3.11

# #Install Miniconda
# #Has to be appended, else messes with qgis
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh && \
#     echo "${CONDA_MD5}  miniconda.sh" > miniconda.md5 && \
#     if ! md5sum --status -c miniconda.md5; then exit 1; fi && \
#     mkdir -p /opt && \
#     sh miniconda.sh -b -p /opt/conda && \
#     rm miniconda.sh miniconda.md5 && \
#     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#     echo "conda activate base" >> ~/.bashrc && \
#     find /opt/conda/ -follow -type f -name '*.a' -delete && \
#     find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
#     /opt/conda/bin/conda clean -afy && \
#     chown -R $NB_UID:$NB_GID /opt/conda
#
# Download and install Micromamba, and initialize Conda prefix.
#   <https://github.com/mamba-org/mamba#micromamba>
#   Similar projects using Micromamba:
#     - Micromamba-Docker: <https://github.com/mamba-org/micromamba-docker>
#     - repo2docker: <https://github.com/jupyterhub/repo2docker>
# Install Python, Mamba and jupyter_core
# Cleanup temporary files and remove Micromamba
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
COPY initial-condarc "${CONDA_DIR}/.condarc"
WORKDIR /tmp
RUN set -x && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        # Should be simpler, see <https://github.com/mamba-org/mamba/issues/1437>
        arch="64"; \
    fi && \
    wget --progress=dot:giga -O /tmp/micromamba.tar.bz2 \
        "https://micromamba.snakepit.net/api/micromamba/linux-${arch}/latest" && \
    tar -xvjf /tmp/micromamba.tar.bz2 --strip-components=1 bin/micromamba && \
    rm /tmp/micromamba.tar.bz2 && \
    PYTHON_SPECIFIER="python=${PYTHON_VERSION}" && \
    if [[ "${PYTHON_VERSION}" == "default" ]]; then PYTHON_SPECIFIER="python"; fi && \
    # Install the packages
    ./micromamba install \
        --root-prefix="${CONDA_DIR}" \
        --prefix="${CONDA_DIR}" \
        --yes \
        "${PYTHON_SPECIFIER}" \
        'mamba' \
        'jupyter_core' && \
    rm micromamba && \
    # Pin major.minor version of python
    mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    clean-layer.sh && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"