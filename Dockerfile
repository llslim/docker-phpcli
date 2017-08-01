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
	&& rm -rf /var/lib/apt/lists/*

# base production configuration for apache PHP module
COPY ./php.ini-development /usr/local/etc/php/php.ini

#set error_log and sendmail_path for container
COPY ./default-docker.ini /usr/local/etc/php/conf.d/default-docker.ini

# MSMTP Configuration for mailhog
COPY ./msmtprc /etc/msmtprc

# download, verify, and install composer
RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
    && curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
    && php composer-setup.php -- --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup* \
		&& composer config -g vendor-dir /usr/local/php/vendor

# set composer to be used by root user without warning
ENV COMPOSER_ALLOW_SUPERUSER 1
		
# add global composer vendor executables to PATH
ENV PATH ${PATH}:/usr/local/php/vendor/bin

# configuring Xdebug
ENV XDEBUGINI_PATH=/usr/local/etc/php/conf.d/xdebug.ini
COPY ./xdebug.ini /tmp/xdebug.ini
RUN pecl install xdebug \
   && echo "zend_extension="`find /usr/local/lib/php/extensions/ -iname 'xdebug.so'` > $XDEBUGINI_PATH \
   && cat /tmp/xdebug.ini >> $XDEBUGINI_PATH

WORKDIR /var/www/html
