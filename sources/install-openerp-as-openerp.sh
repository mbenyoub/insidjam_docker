#!/bin/bash

virtualenv --no-site-packages --python=python2.7 env-openerp

. env-openerp/bin/activate

# update pip
pip install setuptools --upgrade
pip install pip --upgrade
pip install wheel --upgrade

easy_install -UZ /opt/openerp/wheelhouse/PyChart-1.39-py2.7.egg
pip install --no-index --find-links /opt/openerp/wheelhouse -r requirements.txt
# py3o must be unzipped for the external dependency to work in oe
easy_install -UZ "py3o.template"

mkdir -p /opt/openerp/sources
mkdir -p var/log
mkdir -p var/egg-cache
chmod 700 var/egg-cache
