#### webserver (apache+php)
This service uses apache and allows to run ANY kind of PHP based web-application in nearly all PHP versions (good for legacy applications).
It is creating a generated Dockerfile based on the project `.env` settings. 

It is using the docker container `php:{PHP_VERSION}-apache` (PHP version can be configured). Please check [their documentation](https://hub.docker.com/_/php) for more information.

##### Storing web data files
The website files must be copied to `applications/instance-data/{PROJECT}/` (or a sub-folder, depending on the settings `WEB_ROOT_DOCKER_HOST`, `WEB_DIR_APP_HOST` and `WEB_DIR_APP_ALIASES`).

##### Adding new modules/libraries
It's easy to add new modules and libraries to the `webserver` service. Most cases can be covered by configuring the following settings: `PHP_EXTENSIONS`, `APACHE_MODULES` and `APT_LIBS`.
If this is not enough, it's possible to add custom "modules", which are in fact just partial `Dockerfile` pieces. 
To add a new module, it's necessary to create in `applications/custom-services/main/webserver/docker/modules` (or in `docker-data/{PROJECT}/services/main/webserver/docker/modules` for a specific project) a file named `YOUR-MODULE-NAME.Dockerfile` (it's an incomplete/partial Dockerfile) and `YOUR-MODULE-NAME.txt` (with a short description of the new module).
Next step is to run `./project.sh {PROJECT}` for reconfiguration of the setting `DOCKERFILE_MODULES` to add the new module "YOUR-MODULE".

Examples for `YOUR-MODULE.Dockerfile`:
```
# ssmtp.Dockerfile

RUN apt-get install -y --no-install-recommends \
    ssmtp

# Config SSMTP to use our postfix
RUN { \
    echo 'mailhub=postfix:587'; \
    echo 'FromLineOverride=YES'; \
	} > /etc/ssmtp/ssmtp.conf

# Write php.ini
RUN { \
    echo '[mail function]'; \
    echo 'sendmail_path = "/usr/sbin/ssmtp -t"'; \
	} > /usr/local/etc/php/conf.d/ssmtp.ini
```
As shown in this example, it's possible to write files into the container (e.g. to customized php.ini settings)

```
# gd.Dockerfile:

RUN apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev

# Config Extensions
RUN docker-php-ext-configure gd \
            --enable-gd-native-ttf \
            --with-freetype-dir=/usr/include/freetype2 \
            --with-png-dir=/usr/include \
            --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd
```
As demonstrated in this example, it's possible to install and configure additional PHP modules easily (more information in the [php-docker documentation](https://hub.docker.com/_/php#php-core-extensions)). 

##### Multiple domains on one webserver
Most of the time it makes sense to run one website per webserver service (which makes it easy then to move to another server). 
But sometimes it is useful to run multiple website, especially if they
are strongly coupled (relevant settings for this scenario are `WEB_HOST_ALIASES`, `WEB_DIR_APP_HOST` and `WEB_DIR_APP_ALIASES`). 
Downside for this solution is a less independent architecture of projects and security concerns. Because an attacker, which breaks into one website (e.g. old wordpress) can easily 
get access to other websites in the same project-instance.
