# ODBC drivers
RUN apt-get update && \
    apt-get install -y unixodbc-dev && \
    pip install --no-cache-dir --quiet pyodbc && \
    rm -rf /var/lib/apt/lists/* && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
