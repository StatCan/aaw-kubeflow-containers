# ODBC drivers
RUN apt-get update && \
    apt-get install -y alien unixodbc unixodbc-dev && \
    pip install --no-cache-dir --quiet 'pyodbc==4.0.30' && \
    rm -rf /var/lib/apt/lists/*

# Add PGWeb too
ENV PGWEB_VERSION 0.11.7
ARG PGWEB_SHA256=87afd2aa1a087d0e61fa9624178cdf5ea663dec545ae0b6d3c0351f9deacd681
RUN \
  cd /tmp && \
  wget -q https://github.com/sosedoff/pgweb/releases/download/v$PGWEB_VERSION/pgweb_linux_amd64.zip && \
  echo "$PGWEB_SHA256  pgweb_linux_amd64.zip" | sha256sum -c - && \
  unzip pgweb_linux_amd64.zip -d /usr/bin && \
  mv /usr/bin/pgweb_linux_amd64 /usr/bin/pgweb && \
  rm -f pgweb_linux_amd64.zip
