FROM php:7.4-cli
LABEL maintainer="Kevin Williams (@llslim) <info@llslim.com>"

# copy default php.ini into image
COPY php.ini /usr/local/etc/php/

# load php module configuration files
COPY php-conf.d/*.ini /usr/local/etc/php/conf.d/

	
RUN set -eux; \
\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	buildDeps=" \
		libfreetype6-dev \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
		libzip-dev \
	 "; \
	 supportServices=" \
	       msmtp \
	       msmtp-mta \
	   #    gdb \
	 "; \
	  apt-get update; \
	  export DEBIAN_FRONTEND=noninteractive \	  
	  && apt-get install -y --no-install-recommends $supportServices; \
	  savedAptMark="$(apt-mark showmanual)"; \
	  apt-get install -y --no-install-recommends $buildDeps; \
	 # build php extensions with development dependencies, and install them
	 docker-php-ext-configure \
	   gd --with-freetype --with-jpeg; \
	 docker-php-ext-install -j "$(nproc)" gd opcache pdo pdo_mysql pdo_pgsql mysqli zip; \
	  # install xdebug extension
	# pear config-set php_ini /usr/local/etc/php/php.ini; \
	 # pecl install xdebug; \
	 # docker-php-ext-enable xdebug; \
	# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	 apt-mark auto '.*' > /dev/null; \
	 apt-mark manual $savedAptMark; \
	 ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
	   | awk '/=>/ { print $3 }' \
	   | sort -u \
	   | xargs -r dpkg-query -S \
	   | cut -d: -f1 \
	   | sort -u \
	   | xargs -rt apt-mark manual; \
	 \
	 apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	  rm -rf /var/lib/apt/lists/*
	  
# copy msmtp config files
COPY ./msmtprc /etc/msmtprc

# download and load nodejs debian packages to be activated on the next
# `apt-get install nodejs` command
# install all the devtools needed for php cli command line tools (e.g. drush, wp-cli)
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - ; \
apt-get update ; apt-get install -y --no-install-recommends \
			git \
			less \
			default-mysql-client \
			openssh-client \
			ca-certificates \
			nodejs \
			rsync \
			tar \
			unzip \
			sudo \
			zip ; \
			rm -rf /var/lib/apt/lists/*

# install composer
COPY composer-setup.sh /tmp/
RUN chmod +x /tmp/composer-setup.sh && /tmp/composer-setup.sh

# install drupal launcher
RUN curl https://drupalconsole.com/installer -L -o drupal.phar \
&& mv drupal.phar /usr/local/bin/drupal \
&& chmod +x /usr/local/bin/drupal

# create user dev
RUN groupadd -r dev -g 1000 && useradd --uid 1000 --no-log-init -m -d /home/dev -s /bin/bash -r \
	-g dev -G sudo,www-data,staff dev && echo "dev:w3bd3v" | chpasswd

COPY .bashrc /home/dev
RUN chown -R dev.dev /home/dev

# create working directory and give permissions to the 'www-data' user group
RUN mkdir -p /var/www/html && chown -R dev:www-data /var/www && chmod -R +664 /var/www

USER dev
ENV HOME /home/dev

# Setting up composer
RUN mkdir /home/dev/.composer && chown -R dev /home/dev/.composer
COPY composer.jtxt /home/dev/.composer/composer.json
#RUN composer global install

WORKDIR /var/www/html
# RUN composer global require drush/drush drupal/console && /home/dev/.composer/vendor/bin/drush init -y

CMD /bin/bash
