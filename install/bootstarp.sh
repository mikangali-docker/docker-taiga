#!/bin/bash

# Get default params
source /etc/environment

main(){
  # Firt run init Taiga
  if [ -f "$TAIGA_HOME_DIR/install.sh" ]; then
    init
  fi

  echo "Starting taiga ..."
  /usr/bin/supervisord -c $TAIGA_HOME_DIR/supervisord.conf
}

init(){

  echo "`date +'%Y-%m-%d %H:%M:%S'` Init Taiga ..."

  CONF_DIR=$TAIGA_HOME_DIR/conf

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

  ################################
  # Update config files
  ################################

  for i in "${!PARAMS[@]}"
  do
    sed -i -- 's,'"$i"','"${PARAMS[$i]}"',g' $CONF_DIR/*
  done

  sudo -u taiga cp $CONF_DIR/taiga-back-local.py $TAIGA_HOME_DIR/taiga-back/settings/local.py
  sudo -u taiga cp $CONF_DIR/taiga-front-conf.json $TAIGA_HOME_DIR/taiga-front-dist/dist/conf.json
  sudo -u taiga cp $CONF_DIR/taiga-events-config.json $TAIGA_HOME_DIR/taiga-events/config.json

  sudo cp $CONF_DIR/circus-taiga.ini /etc/circus/conf.d/circus-taiga.ini
  sudo cp $CONF_DIR/circus-taiga-celery.ini /etc/circus/conf.d/circus-taiga-celery.ini
  sudo cp $CONF_DIR/circus-taiga-events.ini /etc/circus/conf.d/circus-taiga-events.ini

  ################################
  # Setup RABBITMQ
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
# Import sample data 
################################
if [ "$TAIGA_IMPORT_SAMPLE_DATA" == "True" ]; then
echo "IMPORTING SAMPLE DATA ..."
sudo /etc/init.d/postgresql start 9.5
su - taiga <<'EOF'
    cd taiga-back
    source /etc/bash_completion.d/virtualenvwrapper
    mkvirtualenv -p /usr/bin/python3.5 taiga
    workon taiga
    python manage.py sample_data
EOF
sudo /etc/init.d/postgresql stop 9.5
fi

  ################################
  # Delete unecessary files
  ################################

  rm -rf conf
  rm install.sh

  ################################
  # START TAIGA
  ################################
}

# run this script
main 