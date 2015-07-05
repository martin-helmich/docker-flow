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
    chown flow.flow Configuration/Settings.yaml
else
    echo "WARNING: There is no database container linked into this container."
    echo "         Is this done on purpose? Otherwise create a mariadb:latest container"
    echo "         and link it into this one using the following flag:"
    echo ""
    echo "             --link <db-container-name>:db"
fi

exec /usr/bin/supervisord