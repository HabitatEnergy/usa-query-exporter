FROM python:3.10-slim-bullseye AS build-image

RUN apt-get update
RUN apt-get full-upgrade -y
RUN apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    default-libmysqlclient-dev \
    libpq-dev \
    pkg-config \
    unixodbc-dev \
    unzip

COPY . /srcdir

RUN python3 -m venv /virtualenv
ENV PATH="/virtualenv/bin:$PATH"
RUN pip install \
    /srcdir \
    psycopg2

RUN curl \
    https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip \
    -o instantclient.zip
RUN unzip instantclient.zip
RUN mkdir -p /opt/oracle/instantclient
RUN mv instantclient*/* /opt/oracle/instantclient


FROM python:3.10-slim-bullseye

RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    libaio1 \
    libmariadb-dev-compat \
    libodbc1 \
    libpq5 \
    libxml2 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    (. /etc/os-release; echo "deb https://packages.microsoft.com/debian/$VERSION_ID/prod $VERSION_CODENAME main") > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man && \
    apt-get clean

COPY --from=build-image /virtualenv /virtualenv
COPY --from=build-image /opt /opt
COPY --from=build-image /srcdir /app

ENV PATH="/virtualenv/bin:$PATH"
ENV VIRTUAL_ENV="/virtualenv"
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient"

EXPOSE 9560/tcp
# IPv6 support is not enabled by default, only bind IPv4
ENTRYPOINT ["query-exporter", "/config.yaml", "-H", "0.0.0.0"]
