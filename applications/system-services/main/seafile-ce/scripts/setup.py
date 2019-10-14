#!/usr/bin/python

import MySQLdb
import os
import configparser

###################################
# MySQL
###################################

# Open database connection as root
db = MySQLdb.connect("mariadb","root", os.environ['MARIADB_ROOT_PASSWORD'] )

# prepare a cursor object using cursor() method
cursor = db.cursor()

try:
    cursor.execute("SHOW DATABASES LIKE 'seahub-db'")
    row = cursor.fetchone()

    if row[0] != "seahub-db":
        cursor.execute("CREATE DATABASE IF NOT EXISTS `ccnet-db` character set = 'utf8'")
        cursor.execute("GRANT ALL PRIVILEGES ON `ccnet-db`.* to `%s`@%%;" % os.environ['MARIADB_USER'])

        cursor.execute("CREATE DATABASE IF NOT EXISTS `seafile-db` character set = 'utf8'")
        cursor.execute("GRANT ALL PRIVILEGES ON `seafile-db`.* to `%s`@%%;" % os.environ['MARIADB_USER'])

        cursor.execute("CREATE DATABASE IF NOT EXISTS `seahub-db` character set = 'utf8'")
        cursor.execute("GRANT ALL PRIVILEGES ON `seahub-db`.* to `%s`@%%;" % os.environ['MARIADB_USER'])

except:
   print "Error: unable execute database creation"

# disconnect from server
db.close()

# TODO !!!!!!!!!!!!!!!!!!!!!!!!!!¨

####################################
## Write config
####################################
#
#config = configparser.ConfigParser()
#config.read('FILE.INI')
#print(config['DEFAULT']['path'])     # -> "/path/name/"
#config['DEFAULT']['path'] = '/var/shared/'    # update
#config['DEFAULT']['default_message'] = 'Hey! help me!!'   # create
#
#with open('FILE.INI', 'w') as configfile:    # save
#    config.write(configfile)
#
#
#
#    admin_pw = {
#        'email': get_conf('SEAFILE_ADMIN_EMAIL', 'me@example.com'),
#        'password': get_conf('SEAFILE_ADMIN_PASSWORD', 'asecret'),
#    }
#    password_file = join(topdir, 'conf', 'admin.txt')
#    with open(password_file, 'w') as fp:
#        json.dump(admin_pw, fp)
#
#
####################################
## Configuring seafile
####################################
#https://download.seafile.com/published/seafile-manual/config/ccnet-conf.md
#
#
#
#conf/ccnet.conf -> https://download.seafile.com/published/seafile-manual/config/ccnet-conf.md
#conf/seafile.conf -> https://download.seafile.com/published/seafile-manual/config/seafile-conf.md
#conf/seafdav.conf -> https://download.seafile.com/published/seafile-manual/extension/webdav.md
#conf/seafevents.conf -> https://download.seafile.com/published/seafile-manual/config/seafevents-conf.md
#
## Important settings for our setup (https://download.seafile.com/published/seafile-manual/config/seahub_settings_py.md)
#
#RUN echo "${SEAFILE_VERSION}" > /home/seafile/conf/VERSION
#
#RUN {   MY_HOSTS="'${WEB_HOST}'"; \
#        for host in "${WEB_HOST_ALIASES}"; do; MY_HOSTS="$MY_HOSTS,'$host'"; done; \
#        echo "ALLOWED_HOSTS = [$MY_HOSTS]"; \
#	} >> /home/seafile/conf/seahub_settings.py
#
#RUN {   echo "EMAIL_USE_TLS = False"; \
#        echo "EMAIL_HOST = 'smtp.example.com'"; \
#        echo "EMAIL_HOST_USER = 'username@example.com'"; \
#        echo "EMAIL_HOST_PASSWORD = 'password'"; \
#        echo "EMAIL_PORT = 25"; \
#        echo "DEFAULT_FROM_EMAIL = EMAIL_HOST_USER"; \
#        echo "SERVER_EMAIL = EMAIL_HOST_USER"; \
#        echo "ADD_REPLY_TO_HEADER = True"; \
#    } >> /home/seafile/conf/seahub_settings.py
#
#RUN {   CACHES = {
#            'default': {
#                'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
#                'LOCATION': '127.0.0.1:11211',
#            },
#            'locmem': {
#                'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
#            },
#        }
#        COMPRESS_CACHE_BACKEND = 'locmem'
#    } >> /home/seafile/conf/seahub_settings.py
#
## TODO configure fuse: https://download.seafile.com/published/seafile-manual/extension/fuse.md
#
#
#TODO run upgrade scripts
#https://download.seafile.com/published/seafile-manual/deploy/upgrade.md
