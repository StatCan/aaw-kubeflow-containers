FROM aaw-jupyterlab as aaw-jupyterlab-sas

ENV PATH=$PATH:/usr/local/SASHome/SASFoundation/9.4/bin
ENV PATH=$PATH:/usr/local/SASHome/SASPrivateJavaRuntimeEnvironment/9.4/jre/bin
ENV SAS_HADOOP_JAR_PATH=/opt/hadoop

ENV SASPY_VERSION="5.4.0"

ENV PYTHON_VERSION="3.11"

ARG AZURE_ACCOUNT_NAME=jupyter
ENV ACCOUNT_NAME=${AZURE_ACCOUNT_NAME}

ARG AZURE_ACCOUNT_KEY
ENV ACCOUNT_KEY=${AZURE_ACCOUNT_KEY}

RUN pip3 --no-cache-dir install --quiet \
    sas_kernel

RUN groupadd -g 1337 supergroup && \
    useradd -m sas && \
    usermod -a -G supergroup sas && \
    groupadd -g 1002 sasstaff && \
    usermod -a -G sasstaff sas && \
    echo "sas:sas" | chpasswd

COPY --from=SASHome /usr/local/SASHome /usr/local/SASHome

# maybe we can remove this?
COPY --from=minio/mc:RELEASE.2022-03-17T20-25-06Z /bin/mc /usr/local/bin/mc-original

RUN ln -s /usr/local/SASHome/SASFoundation/9.4/bin/sas_en /usr/local/bin/sas && \
    usermod -a -G sasstaff jovyan && \
    chmod -R 0775 /usr/local/SASHome/studioconfig

WORKDIR /home/sas
RUN /usr/local/SASHome/SASFoundation/9.4/utilities/bin/setuid.sh

# SASPY
COPY sascfg.py /opt/conda/lib/python${PYTHON_VERSION}}/site-packages/saspy/sascfg.py
RUN jupyter nbextension install --py sas_kernel.showSASLog && \
    jupyter nbextension enable sas_kernel.showSASLog --py && \
    jupyter nbextension install --py sas_kernel.theme && \
    jupyter nbextension enable sas_kernel.theme --py && \
    jupyter nbextension list

# Jupyter SASStudio Proxy
COPY jupyter-sasstudio-proxy/ /opt/jupyter-sasstudio-proxy/
RUN pip3 install /opt/jupyter-sasstudio-proxy/

# SAS GConfid
COPY G-CONFID107003ELNX6494M7/ /usr/local/SASHome/gensys/G-CONFID107003ELNX6494M7/
COPY sasv9_local.cfg /usr/local/SASHome/SASFoundation/9.4/

# Enable X command on SAS Studio
COPY spawner_usermods.sh /usr/local/SASHome/studioconfig/spawner/

RUN useradd -m sas && \
    groupadd -g 1001 sasstaff && \
    usermod -a -G sasstaff sas && \
    echo -e "sas" | /usr/bin/passwd --stdin sas

# BlobPorter
RUN curl -L https://github.com/Azure/blobporter/releases/download/v0.6.20/bp_linux.tar.gz -o /tmp/blobporter.tar.gz && \
    tar -xf /tmp/blobporter.tar.gz -C /tmp linux_amd64/blobporter && \
    mv /tmp/linux_amd64/blobporter /usr/local/bin/blobporter && \
    rm -rf /tmp/* && \
    chmod a+x /usr/local/bin/blobporter

RUN cd /usr/local/ && \
    blobporter -c sas -n SASHome-Studio-20190620.tgz -t blob-file && \
    tar -xzpf SASHome-Studio-20190620.tgz && \
    rm SASHome-Studio-20190620.tgz && \
    chown -R sas:sasstaff /usr/local/SASHome && \
    ln -s /usr/local/SASHome/SASFoundation/9.4/bin/sas_en /usr/local/bin/sas

ADD scripts/* /

WORKDIR /home/sas
ENV PATH=$PATH:/usr/local/SASHome/SASFoundation/9.4/bin
ENV PATH=$PATH:/usr/local/SASHome/SASPrivateJavaRuntimeEnvironment/9.4/jre/bin

RUN /usr/local/SASHome/SASFoundation/9.4/utilities/bin/setuid.sh

EXPOSE 8561 8591 38080

ENTRYPOINT ["/bin/bash"]

CMD ["/start.sh"]
