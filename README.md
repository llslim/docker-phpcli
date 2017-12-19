# PHP Command Line (llslim/phpcli)
A Docker container to provide a BASH Shell for maintenance on  applications written in PHP.

This container most often is a companion to the [llslim/docker-apache-php Web Service](https://hub.docker.com/r/llslim/docker-apache-php/). It allows a developer to use the command line tools of composer and nodejs in a separate container, and run the devtools only when need it.

I use it to build drupal websites through the command line tools of drush and drupal console which needs access to the database container running in a docker-compose environment.



By default this specific container is configured to connect to a data service running MySQL. This container is also configured to use the MSMTP Mail User Agent to interpret sendmail calls from the webserver and connect to a mail service.

The default sendmail_path in the php.ini is set up to use the /usr/sendmail program which specified by the msmtp_mta deb package to be a wrapper for the msmtp program.

The default mail server specified in the msmtprc is a local “mail” server most commonly defined in a docker-compose.yml orchestration file. Most often I use a container built with mailhog mail server. By default a mailhog container expose and listens to port 1025. The /etc/msmtprc file should reflect that setting.

Error logging paths will be set to the /dev/stderr so docker can display them when we run `docker logs <container_name or ID>`.

This container is intended to be use for local testing and development of a PHP web application. Hardening measures for security against malicious attacks is not a high priority for this container project. So using this container in a production environment is NOT recommended.
