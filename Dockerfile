FROM xcgd/ubuntu4base
MAINTAINER alexandre.allouche@xcg-consulting.fr

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
ADD http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb /opt/sources/wkhtmltox.deb
RUN dpkg -i /opt/sources/wkhtmltox.deb

# create the odoo user
RUN adduser --home=/opt/odoo --disabled-password --gecos "" --shell=/bin/bash odoo

# ADD sources for the oe components
# ADD an URI always gives 600 permission with UID:GID 0 => need to chmod accordingly
# /!\ carefully select the source archive depending on the version
ADD https://wheelhouse.openerp-experts.net/odoo/odoo9.tgz /opt/odoo/odoo.tgz
RUN chown odoo:odoo /opt/odoo/odoo.tgz


# changing user is required by openerp which won't start with root
# makes the container more unlikely to be unwillingly changed in interactive mode
USER odoo

RUN /bin/bash -c "mkdir -p /opt/odoo/{bin,etc,sources/odoo,additionnal_addons,data}" && \
    cd /opt/odoo/sources/odoo && \
        tar xzf /opt/odoo/odoo.tgz &&\
        rm /opt/odoo/odoo.tgz

RUN /bin/bash -c "mkdir -p /opt/odoo/var/{run,log,egg-cache}"


# Execution environment
USER 0
ADD sources/odoo.conf /opt/odoo/etc/odoo.conf
WORKDIR /app
VOLUME ["/opt/odoo/var", "/opt/odoo/etc", "/opt/odoo/additionnal_addons", "/opt/odoo/data"]
# Set the default entrypoint (non overridable) to run when starting the container
ENTRYPOINT ["/app/bin/boot"]
CMD ["help"]
# Expose the odoo ports (for linked containers)
EXPOSE 8069 8072
ADD bin /app/bin/
