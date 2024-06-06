FROM zone-jupyterlab as zone-jupyterlab-sas

ENV PATH=$PATH:/usr/local/SASHome/SASFoundation/9.4/bin
ENV PATH=$PATH:/usr/local/SASHome/SASPrivateJavaRuntimeEnvironment/9.4/jre/bin

ENV SAS_HADOOP_JAR_PATH=/opt/hadoop

ENV PYTHON_VERSION="3.11"

USER root
RUN groupadd -g 1002 sasstaff && \
    usermod -a -G sasstaff jovyan && \
    echo "jovyan:jovyan" | chpasswd

# BlobPorter

ARG AZURE_ACCOUNT_NAME=${storage_account_name}
ENV ACCOUNT_NAME=${AZURE_ACCOUNT_NAME}

ARG SRC_ACCOUNT_KEY=${SRC_ACCOUNT_KEY}
ENV SRC_ACCOUNT_KEY=${SRC_ACCOUNT_KEY}

RUN curl -L https://github.com/Azure/blobporter/releases/download/v0.6.20/bp_linux.tar.gz -o /tmp/blobporter.tar.gz && \
    tar -xf /tmp/blobporter.tar.gz -C /tmp linux_amd64/blobporter && \
    mv /tmp/linux_amd64/blobporter /usr/local/bin/blobporter && \
    rm -rf /tmp/* && \
    chmod a+x /usr/local/bin/blobporter

RUN cd /usr/local/ && \
    blobporter -f https://bryantestsas.blob.core.windows.net/sasblobcontainer/SASHome.tar.gz -c sasblobcontainer -n SASHome.tar.gz -t blob-file && \
    tar -xzpf SASHome.tar.gz && \
    rm SASHome.tar.gz && \
    chown -R jovyan:sasstaff /usr/local/SASHome && \
    ln -s /usr/local/SASHome/SASFoundation/9.4/bin/sas_en /usr/local/bin/sas

# SASPY

USER root
COPY sascfg.py /opt/conda/lib/python${PYTHON_VERSION}/site-packages/saspy/sascfg.py

RUN mamba install -y sas_kernel saspy notebook jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --user && \
    jupyter nbextension enable varInspector/main

RUN jupyter nbextension install --py sas_kernel.showSASLog && \
    jupyter nbextension enable sas_kernel.showSASLog --py && \
    jupyter nbextension install --py sas_kernel.theme && \
    jupyter nbextension enable sas_kernel.theme --py && \
    jupyter nbextension list

RUN /usr/local/SASHome/SASFoundation/9.4/utilities/bin/setuid.sh
EXPOSE 8561 8591 38080

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
