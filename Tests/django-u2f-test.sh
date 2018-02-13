#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

brew update
brew install python3

VIRTUALENVS_HOME=$HOME/virtualenvs
VENV=$VIRTUALENVS_HOME/django-u2f

mkdir -p $VIRTUALENVS_HOME
virtualenv -p python3 $VENV
source $VENV/bin/activate
pip install Django==1.11.10 django-u2f
git clone git@github.com:gavinwahl/django-u2f $VENV/src
cd $VENV/src/testproj
pip install -r requirements.txt
python manage.py migrate
./mkcert.sh
python manage.py createsuperuser
python manage.py runserver_plus --cert localhost
open https://127.0.0.1:8000/u2f/keys/
