FROM php:7.0-cli
MAINTAINER Kevin Williams (@llslim) <info@llslim.com>

# This is a image for maintaining PHP applications from a bash shell with common PHP command line development tools (e.g. git, rsync, mysql/pgsql, and etc.).

# This image also configures, builds, and installs PHP extensions needed for associated web applications.

# In order to build and use some extensions some dependency packages need to be installed with both the source code and run time library. At the end of the building process the source code of the packages will be removed, but the run time libraries will be marked to remain in order to be used by the extensions.

# Since this image uses the APT package manager to retrieve and install software. The source code and runtimes for each of the three libraries can be installed through metapackages, where separate packages are bundled together. The metapackages are specified in the '$buildDeps' shell variable, and the developer tools are specified in the 'devTools' shell variable to be used in one 'apt-get install' command. Also the build dependencies can be easily removed at the build process with the variable.

# For the common graphics PHP extension, gd, the png and jpeg libraries are needed. For PostGRESQL, the pq library is needed.

RUN set -ex \
	&& buildDeps=' \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libpq-dev \
	' \
  &&  devTools=' \
				git \
				gnupg \
				less \
				mysql-client \
				openssh-client \
				nodejs \
				less \
				rsync \
				tar \
				unzip \
				zip \
	' \
  && markedLibs=' \
		libjpeg62-turbo \
		libpng12-0 \
		libpq5 \
	' \
	&& curl -sL https://deb.nodesource.com/setup_9.x | bash - \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps $devTools \
	&& rm -rf /var/lib/apt/lists/* \

	# build php extensions with development dependencies, and install them
	&& docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring opcache mysql mysqli pdo pdo_mysql pdo_pgsql zip \

	# Mark the library packages that were installed with development as manual
	# so the extensions can use them.
	# PHP will issue 'WARNING' messages without these libraries
	&& apt-mark manual $markedLibs \

	# remove unneeded development sources to reduce size of image
	&& apt-get purge -y --auto-remove $buildDeps

	# load some general php configuration files
	COPY php-*.ini /usr/local/etc/php/conf.d/

	# install composer
	RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
	&& curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
	&& php composer-setup.php -- --install-dir=/usr/local/bin --filename=composer \
	&& rm composer-setup*

# create root diretory and give permissions to the non-root user
RUN mkdir -p /var/www/html && chgrp -R www-data /var/www && chmod -R 2774 /var/www

	# create user dev
	RUN groupadd -r dev && useradd --no-log-init -m -d /home/dev -s /bin/bash -r -g dev -G www-data,staff dev
	COPY .bashrc /home/dev
	RUN chown -R dev.dev /home/dev
	USER dev
	ENV HOME /home/dev
	ENV PATH /usr/local/php/vendor/bin:$PATH

	# VOLUME /var/www/html
	WORKDIR /var/www/html

# RUN composer global require drush/drush drupal/console && /usr/local/php/vendor/bin/drush init -y

CMD /bin/bash
