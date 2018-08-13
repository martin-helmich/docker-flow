FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
        nginx \
        php5.6-fpm \
        php5.6-mcrypt \
        php5.6-mysqlnd \
        php5.6-curl \
        php5.6-gd \
        php5.6-json \
        php5.6-xsl \
        php5.6-cli \
        php5.6-imagick \
        php5.6-mbstring \
        supervisor

RUN useradd -d /var/www flow
RUN echo "daemon off;" >> /etc/nginx/nginx.conf && \
    echo "date.timezone = Europe/Berlin" >> /etc/php/5.6/fpm/php.ini && \
    echo "date.timezone = Europe/Berlin" >> /etc/php/5.6/cli/php.ini && \
    echo "display_errors = on" >> /etc/php/5.6/fpm/php.ini

COPY fpm.conf /etc/php/5.6/fpm/pool.d/www.conf
COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisor/conf.d/flow.conf
COPY start.sh /opt/start.sh

WORKDIR /var/www

VOLUME /var/www/Data/Persistent
EXPOSE 80

ONBUILD ADD . /var/www
ONBUILD RUN chown -R flow.flow /var/www

CMD ["/opt/start.sh"]
