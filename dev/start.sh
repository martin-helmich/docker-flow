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

exec /usr/bin/supervisord