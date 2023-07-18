FROM python:3.10-slim
LABEL maintainer="anhndd"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=2.6.2
ENV AIRFLOW_HOME=/usr/local/airflow

EXPOSE 8080 5555 8793

RUN set -ex \
    && buildDeps=' \
    freetds-dev \
    libkrb5-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    libpq-dev \
    git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
    $buildDeps \
    freetds-bin \
    build-essential \
    default-libmysqlclient-dev \
    apt-utils \
    curl \
    rsync \
    netcat-openbsd \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install --upgrade pip \
    && pip install -U pip setuptools wheel \
    && pip install pytest \
    && pip install pytz \
    && pip install pyOpenSSL==23.1.1 \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install flask-bcrypt \
    && pip install apache-airflow[s3,spark,crypto,celery,postgres,hive,jdbc,ssh]==${AIRFLOW_VERSION} \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-3.10.txt" \
    && pip install apache-airflow-providers-amazon \
    && pip install 'redis==4.5.5' \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base\
    && chown -R airflow: ${AIRFLOW_HOME}

WORKDIR ${AIRFLOW_HOME}
COPY /script/entrypoint.sh /entrypoint.sh
COPY /config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

USER airflow
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"] # set default arg for entrypoint