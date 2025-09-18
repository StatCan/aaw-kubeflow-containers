# SAS
RUN groupadd -g 1337 supergroup && \
    useradd -m sas && \
    usermod -a -G supergroup sas && \
    groupadd -g 1002 sasstaff && \
    usermod -a -G sasstaff sas && \
    echo "sas:sas" | chpasswd

# Dockerfile GIST: https://gist.github.com/Jose-Matsuda/c66dbf758620e4ae6bbd811a7b6471f1 
COPY --chown=jovyan:sasstaff --from=k8scc01covidacr.azurecr.io/sasinstallation:v1 /usr/local/SASHome /usr/local/SASHome

RUN ln -s /usr/local/SASHome/SASFoundation/9.4/bin/sas_en /usr/local/bin/sas 

COPY --from=minio/mc:RELEASE.2025-01-17T23-25-50Z /bin/mc /usr/local/bin/mc-original

RUN apt-get update && apt-get install -y --no-install-recommends \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/sas

ENV PATH=$PATH:/usr/local/SASHome/SASFoundation/9.4/bin

ENV PATH=$PATH:/usr/local/SASHome/SASPrivateJavaRuntimeEnvironment/9.4/jre/bin

# setuid.sh is not working as intended, seemingly cannot find the file so we do this instead.
#RUN /usr/local/SASHome/SASFoundation/9.4/utilities/bin/setuid.sh
RUN chown root /usr/local/SASHome/SASFoundation/9.4/utilities/bin/elssrv && \
    chown root /usr/local/SASHome/SASFoundation/9.4/utilities/bin/sasauth && \
    chown root /usr/local/SASHome/SASFoundation/9.4/utilities/bin/sasperm && \
    chmod 4755 /usr/local/SASHome/SASFoundation/9.4/utilities/bin/elssrv && \
    chmod 4755 /usr/local/SASHome/SASFoundation/9.4/utilities/bin/sasauth && \
    chmod 4755 /usr/local/SASHome/SASFoundation/9.4/utilities/bin/sasperm

ENV SAS_HADOOP_JAR_PATH=/opt/hadoop

EXPOSE 8561 8591 38080

# SASPY

ENV SASPY_VERSION="5.4.0"

RUN pip install --no-cache-dir sas_kernel

COPY sascfg.py /tmp/sascfg.py
RUN PYTHON_VERSION=$(python3 -c "import sys; print(f'python{sys.version_info.major}.{sys.version_info.minor}')") \
    && cp /tmp/sascfg.py /opt/conda/lib/$PYTHON_VERSION/site-packages/saspy/sascfg.py \
    && rm /tmp/sascfg.py

# Jupyter SASStudio Proxy

COPY jupyter-sasstudio-proxy/ /opt/jupyter-sasstudio-proxy/
RUN pip install --no-cache-dir /opt/jupyter-sasstudio-proxy/

# Must be set in deepest image
ENV DEFAULT_JUPYTER_URL=/lab 

# SAS GConfid

COPY G-CONFID107003ELNX6494M7/ /usr/local/SASHome/gensys/G-CONFID107003ELNX6494M7/
COPY sasv9_local.cfg /usr/local/SASHome/SASFoundation/9.4/

# Enable X command on SAS Studio
COPY spawner_usermods.sh /usr/local/SASHome/studioconfig/spawner/
