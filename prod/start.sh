#!/bin/sh

chown flow.flow /var/www/Data/Persistent -R

echo "Initializing TYPO3 Flow..."
cd /var/www

if [ -n "${DB_PORT}" ] ; then
    echo "Adjusting configuration file"
    echo "TYPO3:
  Flow:
    persistence:
      backendOptions:
        host: ${DB_ENV_MYSQL_HOST:-db}
        user: ${DB_ENV_MYSQL_USER}
        dbname: ${DB_ENV_MYSQL_DATABASE}
        password: ${DB_ENV_MYSQL_PASSWORD}" > Configuration/Settings.yaml
else
    echo "WARNING: There is no database container linked into this container."
    echo "         Is this done on purpose? Otherwise create a mariadb:latest container"
    echo "         and link it into this one using the following flag:"
    echo ""
    echo "             --link <db-container-name>:db"
fi

chown -R flow.flow .

echo "Flushing caches..."
su -m -c "./flow flow:cache:flush" flow
if [ $? -ne 0 ] ; then
    echo "Could not flush caches. Something is very wrong!"
    exit 1
fi

if [ -n "${DB_PORT}" ] ; then
    echo "Migrating database..."
    su -m -c "./flow doctrine:migrate" flow
    if [ $? -ne 0 ] ; then
        echo "Could not execute doctrine migrations."
        echo "Set the FLOW_DB_DISABLE environment variable to disable database access."
        exit 1
    fi
fi

echo "Warming up caches..."
su -m -c "./flow flow:cache:warmup" flow
if [ $? -ne 0 ] ; then
    echo "Could not warmup caches. Something is very wrong!"
    exit 1
fi

echo "Setting Flow context in Nginx config"
sed -i -e"s,Production,$FLOW_CONTEXT,g" /etc/nginx/sites-enabled/default

echo "Setting Flow context in FPM config"
sed -i -e"s,Production,$FLOW_CONTEXT,g" /etc/php/5.6/fpm/pool.d/www.conf

mkdir /run/php

exec /usr/bin/supervisord
