# PHP Command Line (llslim/phpcli)
This is a container for maintaining PHP applications from a bash shell with common PHP command line development tools (e.g. git, rsync, mysql/pgsql, and etc.).

The image for this container also configures, builds, and installs PHP extensions needed for associated web applications. For some PHP extensions some dependency packages need to be installed with both the source code and run time library. At the end of the building process the source code of the packages will
be removed, but the run time libraries will be marked to remain in order to be used by the extensions.

Since this image uses the APT package manager to retrieve and install software. The source code and runtimes for each of the three libraries can be installed through metapackages, where separate packages are bundled together. The metapackages are specified in the '$buildDeps' shell variable, and the developer tools are specified in the 'devTools' shell variable to be used in one 'apt-get install' command. Also the build dependencies can be easily removed at the build process with the variable.

For the common graphics PHP extension, gd, the png and jpeg libraries are needed. For PostGRESQL, the pq library is needed.

This container most often is a companion to the [llslim/docker-apache-php Web Service](https://hub.docker.com/r/llslim/docker-apache-php/). It allows a developer to use the command line tools of composer and nodejs in a separate container, and run the devtools only when need it.

By default this specific container is configured to connect to a data service running MySQL. This container is also configured to use the MSMTP Mail User Agent to interpret sendmail calls from the webserver and connect to a mail service.

The default sendmail_path in the php.ini is set up to use the /usr/sendmail program which specified by the msmtp_mta deb package to be a wrapper for the msmtp program.

The default mail server specified in the msmtprc is a local “mail” server most commonly defined in a docker-compose.yml orchestration file. Most often I use a container built with mailhog mail server. By default a mailhog container expose and listens to port 1025. The /etc/msmtprc file should reflect that setting.

Error logging paths will be set to the /dev/stderr so docker can display them when we run `docker logs <container_name or ID>`.

This container is intended to be use for local testing and development of a PHP web application. Hardening measures for security against malicious attacks is not a high priority for this container project. So using this container in a production environment is NOT recommended.
