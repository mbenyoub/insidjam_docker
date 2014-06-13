FROM ubuntu:14.04
MAINTAINER florent.aide@xcg-consulting.fr

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# generate locales
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# DEPS
RUN apt-get update && apt-get -y -q install \
        postgresql-client-9.3 \
        python-setuptools \
        python-software-properties software-properties-common \
        supervisor \
        libxml2 libxslt1-dev libjpeg-turbo8 libsasl2-2 libfreetype6 \
        python2.7 libxrender1 libfontconfig1 poppler-utils

# supervisor global conf to avoid detach
ADD sources/supervisord.conf /etc/supervisor/supervisord.conf

# supervisor application specific conf to run an OpenERP instance
ADD sources/supervisord.openerp7.conf /etc/supervisor/conf.d/supervisord.openerp7.conf

# create the openerp user
RUN adduser --home=/opt/openerp --disabled-password --gecos "" --shell=/bin/bash openerp

# Add our build script
ADD sources/wheelhouse /opt/openerp/wheelhouse

ADD sources/install-openerp-as-openerp.sh /opt/openerp/install.sh
ADD sources/requirements.txt /opt/openerp/requirements.txt

# Run it
RUN easy_install -UZ virtualenv && su - openerp -c "cd /opt/openerp && ./install.sh" && rm /opt/openerp/install.sh

# -----------------------------------------------------------------------------------
# OPENERP user below
# -----------------------------------------------------------------------------------
USER openerp

# ADD sources for the oe components
ADD sources/oe /opt/openerp/oe
ADD sources/wkhtmltopdf-amd64 /opt/openerp/wkhtmltopdf-amd64
RUN mkdir -p /opt/openerp/sources && cd /opt/openerp/sources && tar xzf /opt/openerp/oe/openerp-web.tgz && tar xzf /opt/openerp/oe/openobject-server.tgz && tar xzf /opt/openerp/oe/openobject-addons.tgz

# Expose the openerp port
EXPOSE 8069

# Set the default command to run when starting the container
CMD ["/usr/bin/supervisord", "-n", "-l", "/opt/openerp/var/supervisor/supervisord.log", "-j", "/opt/openerp/var/supervisor/supervisord.pid", "-c", "/etc/supervisor/supervisord.conf"]
