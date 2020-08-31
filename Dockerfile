FROM php:7.4-cli
LABEL maintainer="Kevin Williams (@llslim) <info@llslim.com>"

RUN set -ex; \
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	savedAptMark="$(apt-mark showmanual)"; \
	# installs build dependencies
	apt-get update && apt-get install -y --no-install-recommends \
	libjpeg-dev \
	libpng-dev \
	libpq-dev \
	libonig-dev \
	libzip-dev \
	gnupg; \
	# build php extensions with development dependencies, and install them
	docker-php-ext-configure gd \
		--with-jpeg=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring opcache mysqli pdo pdo_mysql pdo_pgsql zip; \
	# Mark the library packages that were installed with development as manual
	# so the extensions can use them.
	# PHP will issue 'WARNING' messages without these libraries
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark gnupg; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

	# load some general php configuration files
	COPY php-*.ini /usr/local/etc/php/conf.d/

	# download and load nodejs debian packages to be activated on the next
	# `apt-get install nodejs` command
	# install all the devtools needed for php cli command line tools (e.g. drush, wp-cli)
	RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - ; \
	apt-get update ; apt-get install -y --no-install-recommends \
				git \
				less \
				default-mysql-client \
				openssh-client \
				nodejs \
				rsync \
				tar \
				unzip \
				sudo \
				zip ; \
				rm -rf /var/lib/apt/lists/*

	# install composer
	RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
	&& curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
	&& php composer-setup.php -- --install-dir=/usr/local/bin --filename=composer \
	&& rm composer-setup*

	# create user dev
	RUN groupadd -r dev -g 1000 && useradd --uid 1000 --no-log-init -m -d /home/dev -s /bin/bash -r \
	    -g dev -G sudo,www-data,staff dev && echo "dev:w3bd3v" | chpasswd

	COPY .bashrc /home/dev
	RUN chown -R dev.dev /home/dev

	# create working directory and give permissions to the 'www-data' user group
	RUN mkdir -p /var/www/html && chgrp -R www-data /var/www && chmod -R 2774 /var/www

	USER dev
	ENV HOME /home/dev

	# VOLUME /var/www/html
	WORKDIR /var/www/html

# RUN composer global require drush/drush drupal/console && /home/dev/.composer/vendor/bin/drush init -y

CMD /bin/bash
