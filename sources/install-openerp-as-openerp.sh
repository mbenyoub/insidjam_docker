#!/bin/bash

cd ~

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

mkdir -p sources/deps
mkdir -p sources/additionnal_addons
mkdir -p var/log
mkdir -p var/egg-cache
chmod 700 var/egg-cache

cd sources/deps

# get webkit renderer as a binary including patched QT extensions (here for ubuntu server 64 bit)
#wget https://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2
wget https://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2
tar xf wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2
