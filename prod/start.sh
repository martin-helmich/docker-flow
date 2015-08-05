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
        host: db
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

echo "Warming up caches..."
su -m -c "./flow flow:cache:warmup" flow
if [ $? -ne 0 ] ; then
    echo "Could not warmup caches. Something is very wrong!"
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

exec /usr/bin/supervisord
