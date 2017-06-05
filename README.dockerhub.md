# PHP Web Service (llslim/phpweb)
A Docker container to provide a web service for executing applications written in PHP.

The service uses Apache webserver for interpreting the PHP code and enabling applications to display and retrieve data through standard web protocols. Apache also provides connections to other services for data storage and sending e-mail messages.

This container is intended to be use for local testing and development of a PHP web application. Hardening measures for security against malicious attacks is not a high priority for this container project. So using this container in a production environment is NOT recommended.

By default this specific container is configured to connect to a data service running MySQL. This container is also configured to use the MSMTP Mail User Agent to interpret sendmail calls from the webserver and connect to a mail service.

The default sendmail_path in the php.ini is set up to use the /usr/sendmail program which specified by the msmtp_mta deb package to be a wrapper for the msmtp program.

The default mail server specified in the msmtprc is a local “mail” server most commonly defined in a docker-compose.yml orchestration file. Most often I use a container built with mailhog mail server. By default a mailhog container expose and listens to port 1025. The /etc/msmtprc file should reflect that setting.

Error logging paths will be set to the /dev/stderr so docker can display them when we run `docker logs <container_name or ID>`.

## Container Tags

### Dev tags
- Php_xdebug
- php.ini-development

### Available tags and related php container base
- Phpweb:5 => php:5-apache
- Phpweb:5-dev => php:5-apache
- Phpweb:7 => php:7-apache
- Phpweb:7-dev => php:7-apache
