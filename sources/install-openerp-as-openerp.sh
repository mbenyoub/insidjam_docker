#!/bin/bash

cd ~

virtualenv --no-site-packages --python=python2.7 env-openerp

. env-openerp/bin/activate

echo "source ~/env-openerp/bin/activate" >> ~/.bashrc

# update pip
pip install setuptools --upgrade
pip install pip --upgrade
pip install wheel --upgrade

# openerp-server dependencies with forced versions for compatibility
pip install "pyparsing<1.999"
pip install "werkzeug<0.9"
pip install "pywebdav<0.9.8"
# additionnal dependencies for xcg entensions
pip install "genshi"
pip install "psycopg2"
# py3o must be unzipped for the external dependency to work in oe
easy_install -UZ "py3o.template"

mkdir -p sources/deps
mkdir -p sources/additionnal_addons
mkdir -p var/log
mkdir -p var/egg-cache
chmod 700 var/egg-cache

cd sources/deps

# get webkit renderer as a binary including patched QT extensions (here for ubuntu server 64 bit)
wget https://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2
tar xf wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2

# get PIL
wget http://effbot.org/downloads/Imaging-1.1.7.tar.gz
tar xzf Imaging-1.1.7.tar.gz
# this is mandatory on 64 bit systems (ubuntu server 64 bit)
# in order for the linker to find our .so
cd Imaging-1.1.7
mv setup.py setup.py.orig
sed 's/JPEG_ROOT = None/JPEG_ROOT = \("\/usr\/lib\/x86_64-linux-gnu", "\/usr\/include")/' < setup.py.orig | sed 's/ZLIB_ROOT = None/ZLIB_ROOT = JPEG_ROOT/' | sed 's/TIFF_ROOT = None/TIFF_ROOT = JPEG_ROOT/' | sed 's/FREETYPE_ROOT = None/FREETYPE_ROOT = JPEG_ROOT/' > setup.py

# build and install PIL without setuptools support as PIL does not play nice with setuptools
python setup.py build && python setup.py install

# go back to sources
cd ../../
