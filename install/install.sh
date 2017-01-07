#!/bin/bash

TAIGA_HOME_DIR=/home/taiga

sudo -u taiga mkdir -p $TAIGA_HOME_DIR/logs
sudo /etc/init.d/postgresql start 9.5
sudo -u postgres createuser taiga && sudo -u postgres createdb taiga -O taiga

################################
# BACKEND INSTALL
################################

su - taiga <<'EOF'
  source /etc/bash_completion.d/virtualenvwrapper
  mkvirtualenv -p /usr/bin/python3.5 taiga
  workon taiga

  git clone https://github.com/taigaio/taiga-back.git taiga-back
  cd taiga-back
  git checkout stable

  pip install -r requirements.txt
  python manage.py migrate --noinput
  python manage.py loaddata initial_user
  python manage.py loaddata initial_project_templates
  python manage.py loaddata initial_role
  python manage.py compilemessages
  python manage.py collectstatic --noinput
EOF

if [ "$TAIGA_IMPORT_SAMPLE_DATA" == "True" ]; then
  sudo -u taiga python manage.py sample_data
fi 

################################
# FRONTEND INSTALL
################################

su - taiga <<'EOF'
  git clone https://github.com/taigaio/taiga-front-dist.git taiga-front-dist
  cd taiga-front-dist
  git checkout stable
EOF

################################
# EVENTS & ASYNC
################################

sudo npm install -g coffee-script

su - taiga <<'EOF'
  git clone https://github.com/taigaio/taiga-events.git taiga-events
  cd taiga-events
  npm install
EOF



