RUN groupadd -g 1002 sasstaff && \
    usermod -a -G sasstaff jovyan && \
    echo "jovyan:jovyan" | chpasswd

COPY --from=SASHome /usr/local/SASHome/SASFoundation/9.4/ /usr/local/SASHome/SASFoundation/9.4/

# SASPY
ENV SASPY_VERSION="5.4.0"

RUN pip install sas_kernel

# TODO: make Python version ENV var.
COPY sascfg.py /opt/conda/lib/python3.11/site-packages/saspy/sascfg.py

RUN jupyter nbextension install --py sas_kernel.showSASLog && \
    jupyter nbextension enable sas_kernel.showSASLog --py && \
    jupyter nbextension install --py sas_kernel.theme && \
    jupyter nbextension enable sas_kernel.theme --py && \
    jupyter nbextension list
