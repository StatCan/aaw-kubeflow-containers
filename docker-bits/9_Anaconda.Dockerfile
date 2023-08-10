# Install Miniconda
# RUN rm -rf /opt/conda && mkdir -p /opt/conda/bin
# Has to be appended, else messes with qgis
ENV PATH $PATH:/opt/conda/bin

ARG CONDA_VERSION=py39_23.5.2-0
ARG CONDA_SHA256=9829d95f639bd0053b2ed06d1204e60644617bf37dd5cc57523732e0e8d64516

USER root
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh && \
    echo "${CONDA_SHA256}  miniconda.sh" > miniconda.sha256 && \
    if ! sha256sum --status -c miniconda.sha256; then exit 1; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -u -b -p /opt/conda && \
    rm miniconda.sh miniconda.sha256 && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy && \
    chown -R $NB_UID:$NB_GID /opt/conda

# Point R to Artifactory repository
COPY Rprofile.site /tmp/Rprofile.site
RUN mkdir -p /opt/conda/lib/R/etc/ && \
    cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# Point conda to Artifactory repository
RUN conda config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-forge-remote --system && \
    conda config --remove channels conda-forge --system && \
    conda config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-forge-nvidia --system && \
    conda config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-pytorch-remote --system
COPY .condarc /tmp/.condarc
RUN cat /tmp/.condarc > /opt/conda/.condarc && rm /tmp/.condarc
