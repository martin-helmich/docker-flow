#!/bin/sh

chown flow.flow /var/www/Data/Persistent -R

echo "Initializing TYPO3 Flow..."
cd /var/www

if [ -z "${FLOW_DB_DISABLE}" ] ; then
    echo "Adjusting configuration file"
    echo "TYPO3:
  Flow:
    persistence:
      backendOptions:
        host: ${FLOW_DB_HOST}
        dbname: ${FLOW_DB_NAME}
        password: ${FLOW_DB_PASSWORD}
        host: ${FLOW_DB_HOST}" > Configuration/Settings.yaml
    chown flow.flow Configuration/Settings.yaml
fi

echo "Warming up caches..."
su -m -c "./flow flow:cache:warmup" flow
if [ $? -ne 0 ] ; then
    echo "Could not warmup caches. Something is very wrong!"
    exit 1
fi

if [ -z "${FLOW_DB_DISABLE}" ] ; then
    echo "Migrating database..."
    su -m -c "./flow doctrine:migrate" flow
    if [ $? -ne 0 ] ; then
        echo "Could not execute doctrine migrations."
        echo "Set the FLOW_DB_DISABLE environment variable to disable database access."
        exit 1
    fi
fi

exec /usr/bin/supervisord