FROM ubuntu:14.04
MAINTAINER florent.aide@xcg-consulting.fr

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# generate locales
RUN locale-gen fr_FR.UTF-8 && update-locale
RUN echo 'LANG="fr_FR.UTF-8"' > /etc/default/locale

# DEPS
# DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive; apt-get -y -q install python-software-properties software-properties-common build-essential pkg-config
RUN apt-get -y -q install python-setuptools vim-nox python-virtualenv python-setuptools wget

RUN DEBIAN_FRONTEND=noninteractive; apt-get -y -q install libxml2-dev libxslt1-dev libjpeg-turbo8-dev libldap2-dev libsasl2-dev libtiff4-dev libfreetype6-dev
RUN apt-get -y -q install python2.7-dev libyaml-dev libxrender1 libfontconfig1 poppler-utils

# We have a bug in PIL since freetype was upgraded
# see here for details: http://hg.effbot.org/pil-2009-raclette/issue/38/build-fails-with-freetype-251
# so we fix this by readding the directory structure PIL is waiting
RUN cd /usr/include/freetype2 && mkdir freetype && cd freetype && ln -s ../fterrors.h .

# install the postgresql-client and the libpq-dev so we can build the python deps
RUN apt-get -y -q install postgresql-client-9.3 libpq-dev

# install supervisor
RUN apt-get -y -q install supervisor
#RUN mkdir -p /var/log/supervisor

# supervisor global conf to avoid detach
ADD sources/supervisord.conf /etc/supervisor/supervisord.conf

# supervisor application specific conf to run an OpenERP instance
ADD sources/supervisord.openerp7.conf /etc/supervisor/conf.d/supervisord.openerp7.conf

# create the openerp user
RUN adduser --home=/opt/openerp --disabled-password --gecos "" --shell=/bin/bash openerp

# -----------------------------------------------------------------------------------
# OPENERP user below
# -----------------------------------------------------------------------------------

# Add our build script
ADD sources/install-openerp-as-openerp.sh /opt/openerp/install.sh
# Run it
RUN su - openerp -c "cd /opt/openerp && ./install.sh"
RUN rm /opt/openerp/install.sh

RUN apt-get -y -q install libglib2.0-dev libxmlsec1-dev libxmlsec1-openssl

# Run the rest of the commands as the ``openerp`` user
USER openerp

# ADD sources for the web server
ADD sources/oe /opt/openerp/sources/oe
RUN cd /opt/openerp/sources && tar xzf oe/openerp-web.tgz
RUN cd /opt/openerp/sources && tar xzf oe/openobject-server.tgz
RUN cd /opt/openerp/sources && tar xzf oe/openobject-addons.tgz
RUN cd /opt/openerp/sources && tar xzf oe/lasso-2.4.0.tar.gz

# compile and install lasso (SAML2 for python)
RUN cd /opt/openerp/sources/lasso-2.4.0 && ./configure --prefix=/opt/openerp/env-openerp --disable-java --disable-perl --disable-php5 --enable-gtk-doc-html=no --with-python=/opt/openerp/env-openerp/bin/python && make && make install

# install the packages defined by openobject server inside our env
RUN cd /opt/openerp/sources/openobject-server && /opt/openerp/env-openerp/bin/python setup.py develop

# specific need (not for openerp itself but for some modules
RUN /opt/openerp/env-openerp/bin/pip install --upgrade sh
RUN /opt/openerp/env-openerp/bin/pip install --upgrade requests

# We do not create this dir... it must be provided at run time
#RUN mkdir -p /opt/openerp/var/supervisor
#RUN mkdir -p /opt/openerp/var/run

# Expose the openerp port
EXPOSE 8069

#VOLUME  ["/var/log/supervisor", "/opt/openerp/var/log"]

# Set the default command to run when starting the container
# CMD ["/opt/openerp/env-openerp/bin/python", "/opt/openerp/sources/openobject-server/openerp-server", "-c", "/etc/openerp/openerp.conf"]
CMD ["/usr/bin/supervisord", "-n", "-l", "/opt/openerp/var/supervisor/supervisord.log", "-j", "/opt/openerp/var/supervisor/supervisord.pid", "-c", "/etc/supervisor/supervisord.conf"]
