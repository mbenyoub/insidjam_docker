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
# install all odoo dependencies as distrib packages when possible as we use the system python
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
        apt-get update && \
        apt-get -yq install \
            adduser \
            postgresql-client-9.3 \
            python \
            python-dateutil python-docutils python-feedparser \
            python-gdata python-jinja2 python-ldap python-libxslt1 \
            python-mako python-mock python-openid python-psutil \
            python-psycopg2 python-pybabel python-pychart python-pydot \
            python-reportlab python-simplejson python-tz \
            python-unittest2 python-vatnumber python-vobject \
            python-xlwt python-yaml python-zsi \
            python-pydot \
            python-genshi \
            python-lasso \
            graphviz \
            ghostscript \
            python-imaging \
            python-matplotlib \
            python-pip \
            python-decorator \
            python-passlib \
            python-serial \
            python-qrcode \
            python-requests \
            python-pypdf 

ADD sources/pip-req.txt /opt/sources/pip-req.txt
# use wheels from our public wheekhouse for proper versions of listed packages
# as described in sourcesd pip-req.txt
# these are python dependencies for odoo when we need precompiled versions
RUN pip install --upgrade --use-wheel --no-index --find-links=https://wheelhouse.openerp-experts.net -r /opt/sources/pip-req.txt

# must unzip this package to make it visible as an odoo external dependency
RUN easy_install -UZ py3o.template

# install wkhtmltopdf based on QT5
ADD sources/wkhtmltox-0.12.1_linux-trusty-amd64.deb /opt/sources/wkhtmltox-0.12.1_linux-trusty-amd64.deb
RUN dpkg -i /opt/sources/wkhtmltox-0.12.1_linux-trusty-amd64.deb

# create the openerp user
RUN adduser --home=/opt/odoo --disabled-password --gecos "" --shell=/bin/bash odoo

# -----------------------------------------------------------------------------------
# ODOO user below
# -----------------------------------------------------------------------------------
USER odoo

# ADD sources for the oe components
# ADD always give root permission only
ADD sources/odoo /opt/sources/
RUN /bin/bash -c "mkdir -p /opt/odoo/{bin,etc,sources/odoo,additionnal_addons,data}" && \
    cd /opt/odoo/sources/odoo && \
        tar xzf /opt/sources/odoo.tgz

ADD sources/odoo.conf /opt/odoo/etc/odoo.conf

RUN /bin/bash -c "mkdir -p /opt/odoo/var/{run,log,egg-cache}"

# Expose the odoo port
EXPOSE 8069

VOLUME ["/opt/odoo/var", "/opt/odoo/etc", "/opt/odoo/additionnal_addons", "/opt/odoo/data"]

# Set the default command to run when starting the container
CMD ["/usr/bin/python", "/opt/odoo/sources/odoo/openerp-server", "-c", "/opt/odoo/etc/odoo.conf"]
