# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7-apache

RUN a2enmod rewrite



# install the PHP extensions we need
RUN set -ex \
	&& buildDeps=' \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libpq-dev \
	' \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps \
	&& docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring pdo pdo_mysql pdo_pgsql zip \
	&& apt-mark manual \
		libjpeg62-turbo \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps

# install mstmp to simulate sendmail and connect to mta with php
RUN apt-get install -y --no-install-recommends msmtp msmtp-mta \
	&& rm -rf /var/lib/apt/lists/* \

# copy default configuration files
COPY ./php.ini-development /usr/local/etc/php/php.ini
COPY ./msmtprc /etc/msmtprc
COPY ./default-docker.ini /usr/local/etc/php/conf.d/default-docker.ini

# install xdebug with pecl
RUN pecl install xdebug

# configuring Xdebug
ENV XDEBUGINI_PATH=/usr/local/etc/php/conf.d/xdebug.ini
RUN echo "zend_extension="`find /usr/local/lib/php/extensions/ -iname 'xdebug.so'` > $XDEBUGINI_PATH
COPY ./xdebug.ini /tmp/xdebug.ini
RUN cat /tmp/xdebug.ini >> $XDEBUGINI_PATH
# RUN echo "xdebug.remote_host="`/sbin/ip route|awk '/default/ { print $3 }'` >> $XDEBUGINI_PATH

WORKDIR /var/www/html
