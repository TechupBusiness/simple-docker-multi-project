# Single server multi project setup
This project is a **lightweight** fully featured modular multi-project architecture using docker, 
completely configurable by just one `.env` file per project.

At the moment is is focussing on web-applications and web-APIs, serving all projects (=applications) via a reverse-proxy (traefik) on multiple domains (automatic SSL).
Docker knowledge is not required to get started, all services can be configured in a single `.env` file.
Having Docker knowledge allows to add new and extend existing services (databases, caches, ...). Pull requests are welcome! 

If you need a cloud infrastructure for multiple server (like kubernetes or docker swarm), you better start using another project. 
Cloud functionality will maybe come one day to this project, but not for now.

The "shipped" system services are mostly using official repositories. Therefore all projects created by this setup
will be always up-to-date, even if there is no update in this project. It's just an architecture "helper", not an application.

To get started (for example in the home directory `~/`):
```
git clone https://github.com/TechupBusiness/simple-docker-multi-project.git && cd simple-docker-multi-project && ./install.sh
```
This will help to setup the most basic settings. Behind the scenes it's creating an `.env` file, based on the user input, for the 
containerized reverse-proxy before starting it.

To add the first project type:
```
./project.sh
```
This will guide through the creation of a new project. Behind the scenes it will simply bake together a `.env` file. 
Depending on the service it may do some additional work (e.g. generating a Dockerfile or creating needed folders for content and backups, 
please see [here](#under-the-hood---services-in-the-spot-light) for details on each service).

**NOTE:** Even though there are bash-scripts and many folder, the architecture is simple and straight forward. There are just a few conventions you need
to be aware of, if you want to add or modify services.

**Table of contents**
* [What is this project actually doing for real?](#what-is-this-project-actually-doing-for-real)
* [Shipped easy-to-use services](#shipped-easy-to-use-services)
* [Under the hood - services in the spot-light](#under-the-hood---services-in-the-spot-light)
  * [System service](#system-service)
    * [traefik - reverse-proxy](#traefik---reverse-proxy)
      * [Using the same domain for multiple projects (SEO)](#using-the-same-domain-for-multiple-projects-seo)
    * [restic - backup solution](#restic---backup-solution)
  * [Main services](#main-services)
    * [webserver (apache+php)](#webserver-apachephp)
      * [Storing web data files](#storing-web-data-files)
      * [Adding new modules/libraries](#adding-new-moduleslibraries)
      * [Multiple domains on one webserver](#multiple-domains-on-one-webserver)
      * [Troubleshooting](#troubleshooting)
    * [Ghost](#ghost)
    * [Dropbox](#dropbox)
    * [NextCloud](#nextcloud)
    * [Syncthing](#syncthing)
  * [Extra services](#extra-services)
    * [MariaDB (MySQL)](#mariadb-mysql)
      * [Import sql-file backup](#import-sql-file-backup)
      * [Export sql-file](#export-sql-file)
    * [Redis](#redis)
    * [PostgreSQL](#postgresql)
    * [pgAdmin](#pgadmin)
    * [Email (Postfix server)](#email-postfix-server)
    * [(Cron)jobs](#cronjobs)
    * [PhpMyAdmin](#phpmyadmin)
  * [Scripts](#scripts)
    * [compose.sh](#composesh)
    * [project.sh](#projectsh)
  * [Custom services and service modifications](#custom-services-and-service-modifications)
    * [Architecture](#architecture)
    * [Service structure](#service-structure)
      * [docker-compose.yml](#docker-composeyml)
        * [docker-compose for a specific project](#docker-compose-for-a-specific-project)
      * [scripts.sh](#scriptssh)
      * [template.env](#templateenv)
    * [Extending existing services](#extending-existing-services)
  * [Troubleshooting](#troubleshooting)
  * [Host requirements](#host-requirements)


## What is this project actually doing for real?
1. It is only using existing standard functionality of docker (container software) and docker-compose (=YAML file format processor to run docker container)
1. It ships a set of useful docker-compose files (=predefined configurable services)
1. It ships a pre-defined flexible default folder structure
1. It is wrapping the command-line (in a bash script) to make it easier to run these composed services together as a project
1. It offers an interactive and guided "baking" of `.env` files (e.g. input-helper, descriptions, ...), based on templates
1. It is configurable and extendable

You could still run complex commands, append all configuration file templates into one file, and create a huge docker-compose file manually, or simply use the help of this modular architecture. 

## Shipped easy-to-use services
Services are separated into two categories: "main" and "extra". Main services are the reason for creating a project (e.g. webserver for PHP based applications).
Extra services supports the main service of a project (e.g. a database or email service).

- System (core)
  - [traefik](#traefik---reverse-proxy): reverse proxy to route incoming http/https traffic for multiple domains to your containerized services/applications
  - [restic](#restic---backup-solution): efficient opensource backup solution written in Go. Creates backups of all data within this project
- Main
  - [webserver](#webserver-apachephp): flexible apache webserver for php applications
  - [dropbox](#dropbox): File share cloud provider
  - [ghost](#ghost): publishing application on nodeJS, alternative to wordpress etc.)
  - [nextcloud](#nextcloud): open source, self-hosted file share and communication platform (like Dropbox, Google Drive, Box.com, ...)
  - [nodejs](#nodejs): generic for all node.js applications
  - [syncthing](#syncthing): efficient open source P2P synchronization (Dropbox replacement)
- Extra
  - [email](#email-postfix-server): Postfix server to send emails
  - [jobs](#cronjobs): Cronjobs, includes a backup for database (mariaDB)
  - [mariadb](#mariadb-mysql): Alternative mysql database
  - [phpmyadmin](#phpmyadmin): Control panel for mysql/mariaDB
  - [redis](#redis): String cache
  - [postgresql](#postgresql): PostgreSQL database
  - [pgadmin](#pgadmin): PostgreSQL database admin panel

## Under the hood - services in the spot-light
All services have a file `template.env` which contains all available configuration options (including descriptions). Running `./project.sh {PROJECT}` allows to interactively (re)configure these settings
for a project.

The aim for this architecture is production use, but it should work also for development, ideally having an edited hosts file:
```
project1.local 127.0.0.1
p2.local 127.0.0.1
```
For the service `webserver` you may want to add some custom php.ini settings and enable PHP debugging with the module `xdebug`.

### System service
#### traefik - reverse-proxy
- It creates only SSL routes (redirects non-http to https) and generates all needed certificates automatically. This means full HTTPS without doing anything.
- Offers a web-dashboard to check routes and backends (protected; behind basic authentication)
- New routes for applications (=orchestrated services) are added completely automatically; you only need to set the server's IP for your domain(s) in your DNS.
- No need to configure it manually
- [See project website for more information](https://traefik.io)

![See this traefik architecture image](https://docs.traefik.io/img/architecture.png)

##### Using the same domain for multiple projects (SEO)
It is easy to use the same domain for multiple projects and separate them by a sub-folder (e.g. `mydomain.com/`, `mydomain.com/project2`, `mydomain.com/project3`  ).
This can be helpful for search engine optimization reason, to collect the "link juice" for all content of a business on one domain (e.g. blog, e-commerce shop, info-pages).

To set this up, the same `WEB_HOST` must be used for multiple projects, but these projects need to have different `WEB_PATHS` (multiple per project are possible). 
There should be always also a project listening to the root folder `/`. NOTE: Only the first sub-folder level ist tested. 

Example settings, can be set when running `./project.sh {PROJECT}`:
```
=============== Project 1 =================
WEB_HOST=mydomain.com
WEB_PATHS=/

=============== Project 2 =================
WEB_HOST=mydomain.com
WEB_PATHS=/blog /info

======== Routing result examples ==========
mydomain.com -> Project 1
mydomain.com/blog/mypost -> Project 2
mydomain.com/info -> Project 2
mydomain.com/categories/food -> Project 1
```

#### restic - backup solution
- One of the most efficient and up-to-date backup solution written in Go
- Has built-in de-duplication and uses block-transfer for data
- Create backups of all user-data added to this project
- Daily backups at 2am
- Configurable policy for backup periods
- [See project website for more information](https://restic.net/)

### Main services
Main services are THE main service of a project. They are the reason why someone would want to create a project with this architecture.

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

##### Troubleshooting
###### Infinite redirect loops
Some applications like wordpress create infinite redirect loops because they redirect to HTTP. This happens because the webserver is serving it's content without SSL to the reverse proxy, 
so the application often don't know that they are actually served via HTTPS. The reverse-proxy is then redirecting the HTTP request back to HTTPS and the redirect-game starts again (infinite).
Please see in the docs of your PHP application how to avoid this situation. For wordpress [see here](https://codex.wordpress.org/Administration_Over_SSL#Using_a_Reverse_Proxy).

#### Ghost
Ghost is a publishing platform on nodeJS. See [their website](https://ghost.org/) for more information.

#### Dropbox
The dropbox service allows to sync the data to a private server. See [their website](https://dropbox.com/) for more information about the payed service.

#### NextCloud
NextCloud is like other data "cloud" service, similar to Dropbox, but hosted on a private environment (and therefore no cloud for this project).
It allows to share files with anyone, web-access and offers a proper mobile app, to access data on the go.
In case you are not satisfies with the sync mechanism, you can integrate it with the syncthing services to have the best features of both worlds.
Please see this [example](#docker-compose-for-a-specific-project). See [project website for more information](https://nextcloud.com/).

#### Syncthing
It is a very efficient P2P data synchronization application on folder level. 
To avoid requiring port forwarding for clients, this project includes the relay server in addition to a client (as server copy of all complete data).
[See project website for more information](https://syncthing.net/).

### Extra services
Extra services are additional services supporting the main service like databases, caches, ...

#### MariaDB (MySQL)
This service is using mariaDB as database. For 99.9% of the use-cases this should be a good replacement for mysql. See [here](https://hackr.io/blog/mariadb-vs-mysql) for details.
[See project website for more information](https://mariadb.org/).

##### Import sql-file backup
The fastest solution (performance and manual steps) is to import it via shell. After starting the `mysql` service (`sudo ./compose.sh {PROJECT} up -d mysql`), 
it's only one command-line (execution context should be the main folder, where most *.sh files are):
```bash
cat {PATH_TO}/database.sql | sudo docker exec -i $(sudo ./compose.sh {PROJECT} ps -q mysql) /usr/bin/mysql -uroot -p{MYSQL_ROOT_PW} {DATABASE_NAME}
```
An alternative is the service `phpmyadmin`, which can be added to the project. It allows to maintain the database via web-interface, including the import of SQL files.

##### Export sql-file
```bash
./compose.sh {PROJECT} exec mariadb /usr/bin/mysqldump --user=root --password={MYSQL_ROOT_PASSWORD} {DATABASE_NAME} > {PATH_TO}/database-export.sql
```

#### Redis
This service is a fast (temporary) string cache to improve performance of (web) applications.
[See project website for more information](https://redis.io).

#### PostgreSQL
A very feature-rich and professional open-source database.
[See project website for more information](https://www.postgresql.org/).

#### pgAdmin
Web-based administration interface for PostgreSQL.
[See project website for more information](https://www.pgadmin.org/).

#### Email (Postfix server)
To send emails, every application needs a service for this kind of work. This services sends emails directly, by using postfix. 
To avoid being labeled as spam, it's important to maintain at least a proper SPF entry on all used domains for the host-server ip.
Ideally the applications, which are sending emails, sign all emails with DKIM. This increase the probability that emails don't go to the spam folder.
To setup DKIM on email service level instead, please see [here, how to add it or relay mails to another mail-service](https://github.com/bokysan/docker-postfix).

#### (Cron)jobs
The (cron) jobs service, allows to execute scripts periodically. By default it includes a script which backs up the mysql service database (if used) once per night. 
The only configuration option so far is, how many days the database logs should be kept.

#### PHPMyAdmin
PHPMyAdmin is a web-administration-interface for mysql compatible databases.
[See project website for more information](https://www.phpmyadmin.net/).

## Scripts
* `compose.sh {PROJECT} {COMMAND}`: Controls (e.g. starts and stops) the project application (see [compose.sh commands](#composesh) below for more information)
* `all-compose.sh {COMMAND}`: Run `./compose.sh {PROJECT} {COMMAND}` for all existing projects (that are having `STATUS=enabled` in their `.env` file)
* `install.sh`: Checks the current environment, allows to install needed applications and setup the system services. You can run it as often as you want without damaging anything.
* `project.sh {PROJECT}`: Adds new and edit existing projects. Interactive script to create a projects' `.env` file.
* `service-action.sh`: Executes predefined actions in some services (e.g. backup&restore functionality) in service mariadb

All scripts are tested with Ubuntu Linux.

Note on scripts, allowing interactive setting modification: inputting no value will use the default value from the template (if it's a new project) or keep the existing value which was already
set before (if existing project). The value which will be set is always shown: `========> Set FIELD (default: "value if you dont enter anything") to >:`).
To clear an existing value, `""` will do the job. Required settings (having three exclamation marks `!!!`) can't be skipped, unless there is a default value.

### compose.sh
This script is an important wrapper for executing docker-compose, which constructs the docker-compose command for a specified project and triggers build code for each used service, if available (see [Service structure](#service-structure) for more information). 
Example call: 

```
sudo docker-compose -p "PROJECT-NAME" -f "system-services/main/webserver/docker-compose.yml" -f "system-service/extra/mysql/docker-compose.yml" -f "system-service/extra/email/docker-compose.yml" -f "custom-service/extra/myservice/docker-compose.yml" {COMMAND}
```
To dig deeper into details, the [documentation](https://docs.docker.com/compose/extends/) offers useful information.

Important commands:
* `up -d`: Starts the project (`-d` = as daemon in the background)
* `up -d {service}`: Starts a specific service of your project
* `stop`: Stops all service of the project (take it offline)
* `stop {service}`: Stops a specific service of the project (take it offline)

Please see [docker-compose docs](https://docs.docker.com/compose/reference/overview/) for a complete command-list (e.g. to access logs or the shell of a specific container). Always run
`compose.sh` instead of `docker-compose`, because it reads the `.env` settings and adds additional options to the call.

### project.sh
This script generates the project folder in `applications/docker-data/{MY-PROJECT}` and reads all `template.env` settings from all chosen services. 
It allows to interactively modify all settings in the projects' `.env` file. It can be run for new but also existing projects.

It's possible to exit the interactive configuration any time by pressing `CTRL + C`. Variable values are written to the `.env` file in the moment you press the return key (after entering it). 

## Custom services and service modifications
Custom services can be added in `applications/custom-services/` as `main`- or `extra`-service. You can add the content of `applications/custom-services/` to your own git repository and/or 
create a pull request to include it as a system-services. Working examples for the service structure can be found in `applications/system-services/`, while the most complex service is in `main/webserver`.

### Architecture
All relevant files and folder structures reside in `applications/`.
```
applications
  backups           All services that backups data should write here in a project sub-folder
    - Project1
    - ProjectX          
  cronjobs          All services that creates cronjobs, should write here in a project sub-folder
    - Project1
    - ProjectX
  custom-services   Create you custom services here (they are not tracked by this repository, so you can put them in your own repo)
    extra
    main
  docker-data       The .env file for each project and optional docker-related "meta" data (depending on the service) will be copied here
    - Project1
    - ProjectX
  instance-data     If data is shared with services, it will be placed here
    - Project1
    - ProjectX
  logs              All services that write logs, should write here in a project sub-folder
    - Project1
    - ProjectX  
  system-services   All shipped services are in here
    extra
    general         This is the only core service (and not really a service, it just includes basic settings that are valid for every main service)
    main
```


### Service structure
Services can be located in:
1. `system-services/{main-OR-extra}/{service}`: Contains services that are shipped with this repository
1. `custom-services/{main-OR-extra}/{service}`: The place to add own "global" services (ideally residing in another GIT repository)
1. `docker-data/{PROJECT}/services/{main-OR-extra}/{service}`: The place for very special project specific services

This list also represents the order, in which the default files of a services are loaded. This way you can simply extend existing
services and configuration in a server-specific (global) and project-specific context. 
Please see [Extending existing services](#extending-existing-services) for more information.

Each service should have at least the following default files:
- **description.txt**: Short description of the service
- **[docker-compose.yml](#docker-composeyml)**: Regular docker compose file
- **[scripts.sh](#scriptssh)**: Script file with specific "interface" (possible functions according to a naming schema)
- **[template.env](#templateenv)**: Contains all variables, that are needed to configure the service
- **actions/....sh**: Folder which contains actions (=bash scripts) that a service can offer (e.g. creating backups, restoring - implemented in service [mariadb](#mariadb-mysql) so far)

#### docker-compose.yml
**IMPORTANT:** the directory context for all path specifications is `applications/docker-data/MY-PROJECT`. To access folders like `instance-data` or `logs` or sub-folders of the service, you need to go two folder-levels up first:
```
../../instance-data
../../logs
../../custom-services/main/MyService
```

All "main" services must implement the following labels, to work properly with the general configuration:
```
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.rule=Host:${PROXY_TMP_FE_HOST}"
      - "traefik.frontend.auth.basic.users=${WEB_AUTH_BASIC}"
      - "traefik.frontend.priority=${PROXY_TMP_PRIORITY}"
      - "traefik.port=80"
      - "traefik.frontend.redirect.regex=^https?://(${PROXY_TMP_REGEX_REDIRECT})/(.*)"
      - "traefik.frontend.redirect.replacement=https://${WEB_HOST}/$${2}"
      - "traefik.frontend.redirect.permanent=true"
```
NOTE: Specification of multiple redirects may come in traefik 2.0

##### docker-compose for a specific project
In some cases you may want to add specific services or mountpoints to one project. To do this simply create a new `docker-compose.yml` in your `applications/docker-data/MY-PROJECT` directory.

**Example:**   
You are using Syncthing for your personal data synchronization but want it to be available via Nextcloud (for sharing, web- and mobile access). In addition you have your Dropbox folder, for legacy reasons.

Example requirement: the project name of your syncthing instance is `syncthing`, Dropbox `dropbox` and Nextcloud `nextcloud`.

Place in `applications/docker-data/nextcloud` the following `docker-compose.yml`:
```yaml
version: '3.5'

services:
  nextcloud:
    volumes:
      - ../../instance-data/dropbox:/data_dropbox
      - ../../instance-data/syncthing:/data_syncthing
```

Then you can add Dropbox and Syncthing as external storages in Nextcloud easily (`/data_dropbox` and `/data_syncthing`). Please make sure the projects are all using the same owner uid, otherwise linux user restrictions may apply!

#### scripts.sh
It can contain the following methods, which are triggered (replace "{service}" with the name of your service = folder name of the service):

- **{service}Setup**: This method will be called when the user finished configuration via `./project.sh`
  - Parameter 1: PROJECT
- **{service}Build**: This method will be called when the user runs `./compose.sh` (work that needs to be done prior to building and starting of a container, e.g. modify a Dockerfile) 
  - Parameter 1: PROJECT
- **{service}Instructions**: These are displayed at the end after finishing the configuration of a project via `./project.sh`
  - Parameter 1: PROJECT
- **{service}FieldDescriptions**: You can use a `\[script\]` placeholder in your `template.env` and replace it with the echo of this method if editing interactive using `./project.sh` command
  - Parameter 1: PROJECT
  - Parameter 2: FIELD

You can access the configuration values (here `MY_CONFIG_VAR`) of the current project via:
```bash
PROJECT="$1"
PROJECT_ENV="applications/docker-data/$PROJECT/.env"
MY_CONFIG_VAR="$(configGetValueByFile MY_CONFIG_VAR "$PROJECT_ENV")"
```

**Example for {service}FieldDescriptions:**

.env
```env
#+++++++++++++++++++++++++++++++++
# Special setting
# [SCRIPT]
#---------------------------------
SPECIAL_SETTING=

#+++++++++++++++++++++++++++++++++
# [OPTIONAL] Web directories for your host aliases
#   - Mapping syntax: DOMAIN:FOLDER
# [SCRIPT]
# Example: "alias.tld:folder1 alias2.tld:folder2" (space separated)
#---------------------------------
WEB_DIR_APP_ALIASES=

#+++++++++++++++++++++++++++++++++
# A setting
# [SCRIPT]
#---------------------------------
A_SETTING=
```

scripts.sh (in service "webserver")
```bash
webserverFieldDescriptions() {
    PROJECT="$1"
    FIELD="$2"

    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    if [[ "$FIELD" == "WEB_DIR_APP_ALIASES" ]]; then
        WEB_HOST_ALIASES="$(configGetValueByFile WEB_HOST_ALIASES "$PROJECT_ENV")"
        echo "   - Available domains to map: $WEB_HOST_ALIASES"
    elif [[ "$FIELD" == "A_SETTING" ]]; then
        SPECIAL_SETTING="$(configGetValueByFile SPECIAL_SETTING "$PROJECT_ENV")"
        echo "  - This is relevant!: $SPECIAL_SETTING"
    fi
}
```

#### template.env

The env files need to follow exactly this structure, so it can be made interactive:

```
#+++++++++++++++++++++++++++++++++
# One or
# more lines of descriptions and some optional [tags]
#---------------------------------
VARIABLE=empty or default value
```

Tags with a special functionality:
- `[HIDDEN]`: Will not show up when editing the settings interactively (via `./project.sh`) - used in service `webserver` (they are set in `scripts.sh -> webserverBuild()`)
- `[REQUIRED]`: Fields with this tag needs a value (either provided as default value in `template.env`, newly entered by the user or already set when updating an existing project `.env` file)
- `[BASIC-AUTH]`: If this is set, the user can enter a username and password which will be automatically encrypted to a proper basic-authentication string which traefik supports to protect applications.
- `[SCRIPT]`: Please see the previous chapter [scripts.sh](#scriptssh), how these placeholder will be replaced. 

### Extending existing services
For each service, the data is loaded in the following order (see [Service structure](#service-structure) for full paths):
1. system-services folder
2. custom-services folder
3. project-services folder

You can add the normal default files, to extend an existing service with the same name:
- **description.txt**: The description will be used from the last file occurence (according to loading order) and override all previous descriptions for this service
- **docker-compose.yml**: You can add a regular docker compose file; all will be loaded according to the loading order. Please see the [docker-compse documentation](https://docs.docker.com/compose/extends/) how to extend existing docker-compose files. 
- **scripts.sh**: All methods will run in the loading order (each occurence will be executed). You can not override the output of a (previous) method but you can correct/change its actions (e.g. deleting again a created folder)
- **template.env**: You only need to add new variables, that are needed within your extending `docker-compose.yml` or `scripts.sh`.

This way you are very flexible in modifying an existing service. You can change the image, Dockerfile, etc.

## Troubleshooting
### How can I add my files to the webserver or other services?
Maybe you are used to FTP, to transfer files. I would suggest to use SFTP (the ssh file transfer) - not to confuse with FTPS (FTP via SSL) instead.
Or if possible, use git, wget, composer etc. on the command line to download the files you need.
In case you really need it, you could add a custom-service with an FTP, linked to your data. Please see chapter [Custom services and service modifications](#custom-services-and-service-modifications).

### Browser says: Connection is not secure
If this does not disappear automatically, it means that it could not sucessfully acquire a Let's encrypt SSL certificate.
You need to restart your application service (`./compose.sh {MY-PROJECT} {SERVICE-NAME} stop && ./compose.sh {MY-PROJECT} {SERVICE-NAME} up -d`), so it can try again to get a certificate. This usually happens if
you start the webserver but the domain is still pointing to another server.

### I get the message "WARNING: The WEB_ROOT_DOCKER_HOST variable is not set. Defaulting to a blank string."
This is ok if you did not set a value for this configuration setting. Only if you put your files in a sub-folder of `applications/instance-data/PROJECT`, you need to specify this value.

### I can't scroll trough the output of ./compose.sh MYPROJECT logs
You can use less. Simply run `./compose.sh MYPROJECT logs MYSERVICE | less -R`.

### My certificates are self-signed
Please go to the reverse-proxy logs and check what is written in there: `cd system/reverse-proxy && sudo docker-compose logs | less -R`.

### How can I add my own ENV variables to be accessible within my main service container
This works for `webservice` and `nodejs` so far.
1. The good approach (to allow configuration via `project.sh`):   
Add a custom "extra" service to the project and create a file `template.env`. Please read the chapter "template.env", how this file should look like.
All variables that you add in this file can be edited when you call `./project.sh MY-PROJECT`.
2. The not recommended approach (will **not** allow configuration via `project.sh`):   
Add the variables manually to the projects' `.env` file in `applications/docker-data/MY-PROJECT/.env`.

### How can I add custom mount-points to a project?
This can be done easily. Please see this [example](#docker-compose-for-a-specific-project).

## Host requirements
* 64bit processor
* bash shell