# PHP Command Line (llslim/phpcli)
This is a socker image for maintaining PHP applications from a bash shell with common PHP command line development tools (e.g. git, rsync, mysql/pgsql, and etc.).

This docker image most often is a companion to the [llslim/docker-apache-php Web Service](https://hub.docker.com/r/llslim/docker-apache-php/). It allows a developer to use the command line tools of composer and nodejs in a separate container, and run the devtools only when needed.

This docker image is intended to be use for local testing and development of a PHP web application. Hardening measures for security against malicious attacks is not a high priority for this container project. So using this container in a production environment is NOT recommended.

By default this docker image is configured to connect to a data service running MySQL. This container is also configured to use the MSMTP Mail User Agent to interpret sendmail calls from the webserver and connect to a mail service.

### Configure MSMTP
The default mail server specified in the msmtprc is a local “mail” server most commonly defined in a docker-compose.yml orchestration file. Most often I use a container built with mailhog mail server. By default a mailhog container expose and listens to port 1025. The /etc/msmtprc file should reflect that setting.

## Build and Configure PHP extensions
The image configures, builds, and installs PHP extensions needed for associated web applications. Some PHP extensions require dependency packages to be installed during the build process through the APT package manager. Using APT, the state of installed packages with in the container are marked before the start of the build process. At the end of the build process, the packages used by the PHP extensions will be added to the marked packages, and the unmarked build dependency packages will be purged from the system.

### Add PHP Config files
PHP configuration files are copied into the container into the PHP Config directory (/usr/local/etc/php/conf.d). The files sets the following configuration for the PHP server.

### Configure PHP sendmail
The default sendmail_path in the php.ini is set up to use the /usr/sendmail program which specified by the msmtp_mta deb package to be a wrapper for the msmtp program.

### Configure PHP error log
Error logging paths will be set to the /dev/stderr so docker can display them when we run `docker logs <container_name or ID>`.

## install Command Line development tools
- I use nodesource to download the [nodejs debian package](https://github.com/nodesource/distributions)
- I download and install the composer package manager from the [Official installation guide](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)
- The rest of the devtools are available through APT:
  - git
  - gnupg
  - less
  - mysql-client
  - openssh-client
  - rsync
  - unzip
  - zip
  - libnotify-bin

## Create User and set permissions
Creates the 'dev' user and add it to user group 'www-data' among others.

## Reference image
I base this docker image on the [Docker Official Image for Drupal](https://github.com/docker-library/drupal)

## Run command
`docker run --rm -it llslim/docker-phpcli -v /path/to/web/root:/var/www/html -v ssh-vol:/home/dev/.ssh -v /path/to/conf/drush:/home/dev/.drush -v /path/to/archive:/var/www/archive --network=lamp_server /bin/bash`
