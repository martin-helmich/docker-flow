#!/bin/sh

chown flow.flow /var/www/Data/Persistent -R
exec /usr/bin/supervisord