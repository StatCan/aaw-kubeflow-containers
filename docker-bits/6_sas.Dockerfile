# SAS
FROM k8scc01covidacr.azurecr.io/sas4c:0.0.3 as SASHome
FROM jupyter/datascience-notebook:$BASE_VERSION


RUN pip install --quiet \
    'git+https://github.com/betatim/vscode-binder'


# Install vscode
ARG VSCODE_VERSION=4.5.1
ARG VSCODE_SHA=f43e217706044aea9d8ae4f8ce1185c3ebfadf980bcf668ab94ecccb70e99709
ARG VSCODE_URL=https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

USER root


ENV CS_DISABLE_FILE_DOWNLOADS=1
ENV XDG_DATA_HOME=/etc/share
ENV SERVICE_URL=https://extensions.coder.com/api

RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y nginx \
    && dpkg -i ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && mkdir -p $HOME/.local/share \
    && mkdir -p $XDG_DATA_HOME/code-server/extensions

# Install Quarto
ARG QUARTO_VERSION=1.2.247
ARG QUARTO_SHA=00012da73de3ac6e98715bff127679b12c567b9a56f906163c8997a9e9d7610b
ARG QUARTO_URL=https://github.com/quarto-dev/quarto-cli/releases/download/v1.2.247/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz

RUN wget -q ${QUARTO_URL} -O /tmp/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz && \
    echo "${QUARTO_SHA} /tmp/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" | sha256sum -c - && \
    tar -xzvf /tmp/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz -C /tmp/ && \
    chmod +x /tmp/quarto-${QUARTO_VERSION} && \
    ln -s /tmp/quarto-${QUARTO_VERSION}/bin/quarto /usr/bin/quarto

# Fix for VSCode extensions and CORS
# Languagepacks.json needs to exist for code-server to recognize the languagepack
COPY languagepacks.json $XDG_DATA_HOME/code-server/
ARG SHA256py=10368d0175e34583a84935e691dba122d4ece2e23305700f226b6807508a30b1

RUN code-server --install-extension ms-python.python@2022.16.1 && \
    code-server --install-extension REditorSupport.r@2.7.0 && \
    code-server --install-extension MS-CEINTL.vscode-language-pack-fr@1.68.3 && \
    code-server --install-extension quarto.quarto@1.53.1 && \
    fix-permissions $XDG_DATA_HOME

RUN groupadd -g 1337 supergroup && \
    useradd -m sas && \
    usermod -a -G supergroup sas && \
    groupadd -g 1002 sasstaff && \
    usermod -a -G sasstaff sas && \
    echo "sas:sas" | chpasswd

COPY --from=SASHome /usr/local/SASHome /usr/local/SASHome

COPY --from=minio/mc:RELEASE.2022-03-17T20-25-06Z /bin/mc /usr/local/bin/mc-original

RUN apt-get update && apt-get install -y --no-install-recommends \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/local/SASHome/SASFoundation/9.4/bin/sas_en /usr/local/bin/sas && \
    usermod -a -G sasstaff jovyan && \
    chmod -R 0775 /usr/local/SASHome/studioconfig

WORKDIR /home/sas

ENV PATH=$PATH:/usr/local/SASHome/SASFoundation/9.4/bin

ENV PATH=$PATH:/usr/local/SASHome/SASPrivateJavaRuntimeEnvironment/9.4/jre/bin

RUN /usr/local/SASHome/SASFoundation/9.4/utilities/bin/setuid.sh

ENV SAS_HADOOP_JAR_PATH=/opt/hadoop

EXPOSE 8561 8591 38080

# SASPY

ENV SASPY_VERSION="4.1.0"

RUN pip install sas_kernel

COPY sascfg.py /opt/conda/lib/python3.9/site-packages/saspy/sascfg.py

RUN jupyter nbextension install --py sas_kernel.showSASLog && \
    jupyter nbextension enable sas_kernel.showSASLog --py && \
    jupyter nbextension install --py sas_kernel.theme && \
    jupyter nbextension enable sas_kernel.theme --py && \
    jupyter nbextension list

# Jupyter SASStudio Proxy

COPY jupyter-sasstudio-proxy/ /opt/jupyter-sasstudio-proxy/
RUN pip install /opt/jupyter-sasstudio-proxy/

ENV DEFAULT_JUPYTER_URL=/lab

# SAS GConfid

COPY G-CONFID107003ELNX6494M7/ /usr/local/SASHome/gensys/G-CONFID107003ELNX6494M7/
COPY sasv9_local.cfg /usr/local/SASHome/SASFoundation/9.4/

# Jupyter-resession-proxy
ARG RSTUDIO_VERSION=2022.07.2-576
ARG SHA256=6dc6a71c7a4805e347ab88d9d9574f8898191dfd0bc3191940ee3096ff47fbcd
RUN apt-get update && \
    apt install -y --no-install-recommends software-properties-common dirmngr && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" && \
    apt install -y --no-install-recommends r-base r-base-core r-recommended r-base-dev && \
    apt-get update && apt-get -y dist-upgrade

#install libssl1.1 dependency for rstudio-server on ubuntu 22.04
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RUN curl --silent -L  --fail "https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    #Harden rstudio-server
    echo "www-frame-origin=none" >> /etc/rstudio/rserver.conf && \
    echo "www-enable-origin-check=1" >> /etc/rstudio/rserver.conf && \
    echo "www-same-site=lax" >> /etc/rstudio/rserver.conf && \
    echo "restrict-directory-view=1" >> /etc/rstudio/rsession.conf
ENV PATH=$PATH:/usr/lib/rstudio-server/bin
# Install some default R packages
RUN conda install --quiet --yes \
      'r-rodbc==1.3_19' \
      'r-tidymodels==0.1.3' \
      'r-arrow==4.0.0' \
      'r-aws.s3==0.3.21' \
      'r-catools==1.18.2' \
      'r-hdf5r==1.3.3' \
      'r-odbc==1.3.3' \
      'r-sf==1.0_4' \
      'r-e1071==1.7_8' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN python3 -m pip install \
      'jupyter-rsession-proxy==2.1.0' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER
RUN pip install jupyter-rsession-proxy

# Enable X command on SAS Studio
COPY spawner_usermods.sh /usr/local/SASHome/studioconfig/spawner/