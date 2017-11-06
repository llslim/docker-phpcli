FROM php:7.1-cli
MAINTAINER drupal-docker

VOLUME /var/www/html
WORKDIR /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get update \
  && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
     libxml2-dev sudo git nodejs mysql-client openssh-client \
     rsync less unzip zip tar \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip \
  && docker-php-ext-install opcache bcmath soap \
  && pecl install redis-3.1.1 \
  && docker-php-ext-enable redis

  RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
  && curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
  && php composer-setup.php -- --install-dir=/usr/local/bin --filename=composer \
  && rm composer-setup* \
  && composer config -g vendor-dir /usr/local/php/vendor \
  && echo "export PATH=/usr/local/php/vendor/bin:\$PATH" >> ~/.bashrc \
  && composer global require drush/drush drupal/console

COPY drupal-*.ini /usr/local/etc/php/conf.d/
COPY .bashrc /root
