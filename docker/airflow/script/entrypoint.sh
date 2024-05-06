#!/usr/bin/env bash

TRY_LOOP="20"

: ${REDIS_HOST:="redis"}
: ${REDIS_PORT:="6379"}
: ${REDIS_PASSWORD:=""}

: ${POSTGRES_HOST:="postgres"}
: ${POSTGRES_PORT:="5432"}
: ${POSTGRES_USER:="airflow"}
: ${POSTGRES_PASSWORD:="airflow"}
: ${POSTGRES_DB:="airflow"}

# Defaults and back-compat
: ${AIRFLOW_HOME:="/usr/local/airflow"}
: ${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}
# : ${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=""}}
: ${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR:-Celery}Executor}
: ${LOAD_EX:="y"}
: ${AIRFLOW_ROLE:="Admin"}
: ${AIRFLOW_USERNAME:="admin"}
: ${AIRFLOW_PASSWORD:="admin"}
: ${AIRFLOW_FIRSTNAME:="Anh"}
: ${AIRFLOW_LASTNAME:="Nguyen"}
: ${AIRFLOW_EMAIL:="anhndd3@gmail.com"}

export \
AIRFLOW_HOME \
AIRFLOW__CELERY__BROKER_URL \
AIRFLOW__CELERY__RESULT_BACKEND \
AIRFLOW__CORE__EXECUTOR \
AIRFLOW__CORE__FERNET_KEY \
AIRFLOW__CORE__LOAD_EXAMPLES \
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN \

wait_for_port() {
    local name="$1" host="$2" port="$3"
    local j=0
    while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
        j=$((j+1))
        if [ $j -ge $TRY_LOOP ]; then
            echo >&2 "$(date) - $host:$port still not reachable, giving up"
            exit 1
        fi
        echo "$(date) - waiting for $name... $j/$TRY_LOOP"
        sleep 5
    done
}

AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"

if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" && "${LOAD_EX:=n}" == n ]]
then
    AIRFLOW__CORE__LOAD_EXAMPLES=False
fi

if [ -n $REDIS_PASSWORD ]; then
    REDIS_PREFIX=:${REDIS_PASSWORD}@
else
    REDIS_PREFIX=
fi

AIRFLOW__CELERY__BROKER_URL="redis://$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT/1"
wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"

case "$1" in
    webserver)
        airflow db init
        sleep 5
        airflow users create \
        --username $AIRFLOW_USERNAME \
        --firstname $AIRFLOW_FIRSTNAME \
        --lastname $AIRFLOW_LASTNAME \
        --password $AIRFLOW_PASSWORD \
        --role $AIRFLOW_ROLE \
        --email $AIRFLOW_EMAIL
        airflow webserver
    ;;
    scheduler)
        sleep 10
        airflow "$@"
    ;;
    worker|flower)
        sleep 10
        airflow celery "$@"
    ;;
    version)
        airflow "$@"
    ;;
    *)
        "$@"
    ;;
esac