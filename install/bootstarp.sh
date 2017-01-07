#!/bin/bash

TAIGA_HOME_DIR=/home/taiga
CONF_DIR=$TAIGA_HOME_DIR/conf

: ${TAIGA_HOST:=http://localhost}
: ${TAIGA_SITE_SCHEME:=http}
: ${TAIGA_SITE_DOMAIN:=localhost}
: ${TAIGA_SOCKETS_SCHEME:=ws}
: ${TAIGA_SECRET_KEY:=SECRET_KEY_XXX}
: ${TAIGA_RABBITMQ_PASSWORD:=RABBITMQ_PASSWORD_XXX}
: ${TAIGA_FROM_EMAIL:=noreply@localhost}
: ${TAIGA_SMTP_USE_TLS:=True}
: ${TAIGA_SMTP_HOSTNAME:=mail.localhost}
: ${TAIGA_SMTP_HOST_USER:=taiga@localhost}
: ${TAIGA_SMTP_HOST_PASSWORD:=Taiga2017}
: ${TAIGA_SMTP_PORT:=465}
: ${TAIGA_PUBLIC_REGISTER_ENABLED:=True}
: ${TAIGA_GITHUB_API_CLIENT_ID:=GITHUB_API_CLIENT_SECRET_XXX}
: ${TAIGA_GITHUB_API_CLIENT_SECRET:=GITHUB_API_CLIENT_SECRET_XXX}
: ${TAIGA_IMPORT_SAMPLE_DATA:=True}

declare -A PARAMS

PARAMS[TAIGA_HOME_DIR]=$TAIGA_HOME_DIR
PARAMS[TAIGA_HOST]=$TAIGA_HOST
PARAMS[TAIGA_SITE_SCHEME]=$TAIGA_SITE_SCHEME
PARAMS[TAIGA_SITE_DOMAIN]=$TAIGA_SITE_DOMAIN
PARAMS[TAIGA_SOCKETS_SCHEME]=$TAIGA_SOCKETS_SCHEME
PARAMS[TAIGA_SECRET_KEY]=$TAIGA_SECRET_KEY
PARAMS[TAIGA_RABBITMQ_PASSWORD]=$TAIGA_RABBITMQ_PASSWORD
PARAMS[TAIGA_FROM_EMAIL]=$TAIGA_FROM_EMAIL
PARAMS[TAIGA_SMTP_USE_TLS]=$TAIGA_SMTP_USE_TLS
PARAMS[TAIGA_SMTP_HOSTNAME]=$TAIGA_SMTP_HOSTNAME
PARAMS[TAIGA_SMTP_HOST_USER]=$TAIGA_SMTP_HOST_USER
PARAMS[TAIGA_SMTP_HOST_PASSWORD]=$TAIGA_SMTP_HOST_PASSWORD
PARAMS[TAIGA_SMTP_PORT]=$TAIGA_SMTP_PORT
PARAMS[TAIGA_PUBLIC_REGISTER_ENABLED]=$TAIGA_PUBLIC_REGISTER_ENABLED
PARAMS[TAIGA_GITHUB_API_CLIENT_ID]=$TAIGA_GITHUB_API_CLIENT_ID
PARAMS[TAIGA_GITHUB_API_CLIENT_SECRET]=$TAIGA_GITHUB_API_CLIENT_SECRET
PARAMS[TAIGA_IMPORT_SAMPLE_DATA]=$TAIGA_IMPORT_SAMPLE_DATA

for i in "${!PARAMS[@]}"
do
  sed -i -- 's,'"$i"','"${PARAMS[$i]}"',g' $CONF_DIR/*
done

sudo -u taiga cp $CONF_DIR/taiga-back-local.py $TAIGA_HOME_DIR/taiga-back/settings/local.py
sudo -u taiga cp $CONF_DIR/taiga-front-conf.json $TAIGA_HOME_DIR/taiga-front-dist/dist/conf.json
sudo -u taiga cp $CONF_DIR/taiga-events-config.json $TAIGA_HOME_DIR/taiga-events/config.json

################################
# Circus 
################################

sudo cp $CONF_DIR/circus-taiga.ini /etc/circus/conf.d/circus-taiga.ini
sudo cp $CONF_DIR/circus-taiga-celery.ini /etc/circus/conf.d/circus-taiga-celery.ini
sudo cp $CONF_DIR/circus-taiga-events.ini /etc/circus/conf.d/circus-taiga-events.ini

################################
# Events 
################################

sudo service rabbitmq-server start > /dev/null 2>&1
sudo rabbitmqctl add_user taiga $TAIGA_RABBITMQ_PASSWORD > /dev/null 2>&1
sudo rabbitmqctl add_vhost taiga > /dev/null 2>&1
sudo rabbitmqctl set_permissions -p taiga taiga ".*" ".*" ".*" > /dev/null 2>&1
sudo service rabbitmq-server stop > /dev/null 2>&1

################################
# NGINX
################################

sudo rm /etc/nginx/sites-enabled/default
sudo cp $CONF_DIR/taiga-nginx.vhost-http /etc/nginx/sites-available/taiga.vhost
sudo ln -s /etc/nginx/sites-available/taiga.vhost /etc/nginx/sites-enabled/taiga

################################
# Delete unecessary files
################################

# rm -rf conf
# rm install.sh

################################
# START TAIGA
################################

/usr/bin/supervisord -c $TAIGA_HOME_DIR/supervisord.conf