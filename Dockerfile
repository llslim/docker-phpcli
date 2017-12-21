FROM php:7-cli
MAINTAINER Kevin Williams (@llslim) <info@llslim.com>

VOLUME /var/www/html
WORKDIR /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
&& set -ex \
	&& buildDeps=' \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libpq-dev \
		libxml2-dev \
	' \
  &&  devDeps='git rsync mysql-client openssh-client nodejs less zip unzip tar' \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps $devDeps \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring opcache pdo pdo_mysql pdo_pgsql zip bcmath soap \
	&& apt-mark manual \
		libjpeg62-turbo \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps

  COPY drupal-*.ini /usr/local/etc/php/conf.d/
  COPY .bashrc /root

  RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
  && curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
  && php composer-setup.php -- --install-dir=/usr/local/bin --filename=composer \
  && rm composer-setup* \
  && composer config -g vendor-dir /usr/local/php/vendor \
  && echo "export PATH=/usr/local/php/vendor/bin:\$PATH" >> /root/.bashrc

  RUN composer global require drush/drush drupal/console && /usr/local/php/vendor/bin/drush init -y
