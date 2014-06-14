A dockerfile for Odoo server
============================

`Docker`_ is a way to create virtualized apps that can be distributed as appliances. Let's call them app'liances :)

.. _Docker: https://www.docker.io/

Odoo version
============

This docker builds with a specific version of odoo we manually pin revisions our team has validated.
This is important to do in this way (as opposed to nightly build) because we want to ensure reliability for our clients:

  - openobject-addons 10030
  - openobject-server 5288
  - openerp-web       4181


Prerequisits
============

xcgd/odoo_datastore
-------------------

To run an instance you'll need to have also installed `xcgd/odoo_datastore`_ and to edit the ``/opt/openerp/etc/openerp.conf`` file inside it::

  $ docker run -i -t --name odoo_data xcgd/odoo_datastore true

.. _xcgd/odoo_datastore: https://registry.hub.docker.com/u/xcgd/odoo-datastore/

xcgd/postgresql_datastore
-------------------------

You'll also need to have a datastore for postgreql from `xcgd/postgresql_datastore`_::

  $ docker run -i -t --name postgresql_data xcgd/postgresql_datastore true

.. _xcgd/postgresql_datastore: https://registry.hub.docker.com/u/xcgd/postgresql_datastore/

xcgd/postgresql
---------------

And last but not least you'll need `xcgd/postgresql`_::

  $ docker run --rm --name="pg93" --volumes-from postgresql_data -u root xcgd/postgresql /bin/bash /srv/initdb.sh

And start PG::

  $ docker run --rm --name="pg93" --volumes-from postgresql_data xcgd/postgresql

Start Odoo
----------

On first run only you'll need to initialize everything with (assuming you named your datastore container odoo_data)::

  $ docker run --rm --volumes-from odoo_data -u root xcgd/odoo /bin/bash /opt/openerp/var/takeownership.sh

Finally run your docker, assuming you named your postgresql docker pg93 as we did above::

  $ docker run -p 8069:8069 --rm --name="xcgd.odoo" --link pg93:db --volumes-from odoo_data xcgd/odoo 


WARNING: note that we aliased the postgresl as ``db``. This is MANDATORY since we use this alias in the configuration files.

If docker starts without issues, just open your favorite browser and point it to http://localhost:8069

Security Notes
==============

You'll note that we did not open ports to the outside world on the PostgreSQL container. This is for security reasons, NEVER RUN your Postgresql container with ports open to the outside world... Just link the openerp container to it as we did above.

This is really important to understand. Posgtgresql is configured to trust everyone so better keep it firewalled. And before yelling madness please consider this: If someone gains access to your host and is able to launch a container and open a port for himself he's got your data anyways... he's on your machine. So keep that port closed and secure your host. You database is as safe as your host is, no more.
