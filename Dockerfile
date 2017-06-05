# from https://www.drupal.org/requirements/php#drupalversions
FROM php:5-apache

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
# PHP Warning:  PHP Startup: Unable to load dynamic library '/usr/local/lib/php/extensions/no-debug-non-zts-20151012/gd.so' - libjpeg.so.62: cannot open shared object file: No such file or directory in Unknown on line 0
# PHP Warning:  PHP Startup: Unable to load dynamic library '/usr/local/lib/php/extensions/no-debug-non-zts-20151012/pdo_pgsql.so' - libpq.so.5: cannot open shared object file: No such file or directory in Unknown on line 0
	&& apt-mark manual \
		libjpeg62-turbo \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps

# install mstmp to simulate sendmail and connect to mta with php
RUN apt-get install -y --no-install-recommends msmtp msmtp-mta php5-xdebug \
	&& rm -rf /var/lib/apt/lists/* \

COPY ./php.ini-development /usr/local/etc/php/php.ini
COPY ./msmtprc /etc/msmtprc
COPY ./default-docker.ini /usr/local/etc/php/conf.d/default-docker.ini

WORKDIR /var/www/html
