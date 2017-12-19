FROM php:7-apache
MAINTAINER Kevin (@llslim)

VOLUME /var/www/html

RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev libxml2-dev \
	msmtp msmtp-mta \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip \
	&& docker-php-ext-install opcache bcmath soap \
	&& pecl install xdebug \
	&& docker-php-ext-enable xdebug \
	&& a2enmod rewrite

COPY drupal-*.ini /usr/local/etc/php/conf.d/

COPY msmtprc /etc/msmtprc
