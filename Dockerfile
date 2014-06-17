FROM ubuntu:14.04
MAINTAINER florent.aide@xcg-consulting.fr

# generate locales
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
        apt-get update && apt-get -y -q install \
            postgresql-client-9.3 \
            supervisor adduser python postgresql-client \
            python-dateutil python-docutils python-feedparser \
            python-gdata python-jinja2 python-ldap python-libxslt1 \
            python-lxml python-mako python-mock python-openid python-psutil \
            python-psycopg2 python-pybabel python-pychart python-pydot \
            python-pyparsing python-reportlab python-simplejson python-tz \
            python-unittest2 python-vatnumber python-vobject python-webdav \
            python-werkzeug python-xlwt python-yaml python-zsi \
            python-pydot \
            python-genshi \
            python-lasso \
            graphviz \
            ghostscript \
            python-imaging \
            python-matplotlib \
            python-pip

RUN easy_install -UZ py3o.template
RUN pip install --upgrade pyjon.utils

# supervisor global conf to avoid detach
ADD sources/supervisord.conf /etc/supervisor/supervisord.conf

# supervisor application specific conf to run an OpenERP instance
ADD sources/supervisord.openerp7.conf /etc/supervisor/conf.d/supervisord.openerp7.conf

# create the openerp user
RUN adduser --home=/opt/openerp --disabled-password --gecos "" --shell=/bin/bash openerp

# -----------------------------------------------------------------------------------
# OPENERP user below
# -----------------------------------------------------------------------------------
USER openerp

# ADD sources for the oe components
ADD sources/oe /opt/openerp/oe
RUN /bin/bash -c "mkdir -p /opt/openerp/{bin,etc,sources,additionnal_addons}" && \
    cd /opt/openerp/sources && \
        tar xzf /opt/openerp/oe/openerp-web.tgz && \
        tar xzf /opt/openerp/oe/openobject-server.tgz && \
        tar xzf /opt/openerp/oe/openobject-addons.tgz

ADD sources/openerp.conf /opt/openerp/etc/openerp.conf
ADD sources/wkhtmltopdf-amd64 /opt/openerp/bin/wkhtmltopdf-amd64


RUN /bin/bash -c "mkdir -p /opt/openerp/var/{supervisor,run,log,egg-cache}"

# Expose the openerp port
EXPOSE 8069

VOLUME ["/opt/openerp/var", "/opt/openerp/etc", "/opt/openerp/additionnal_addons"]

# Set the default command to run when starting the container
CMD ["/usr/bin/supervisord", "-n", "-l", "/opt/openerp/var/supervisor/supervisord.log", "-j", "/opt/openerp/var/supervisor/supervisord.pid", "-c", "/etc/supervisor/supervisord.conf"]
