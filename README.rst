A dockerfile for Odoo server
============================

`Docker`_ is a way to create virtualized apps that can be distributed as appliances. Let's call them app'liances :)

.. _Docker: https://www.docker.io/

Odoo version
============

This docker builds with a specific version of odoo we manually pin revisions our team has validated.
This is important to do in this way (as opposed to nightly build) because we want to ensure reliability for our clients:
from https://github.com/odoo/odoo.git
  - odoo	7.0	dd4d72d710


Prerequisites
=============

xcgd/postgresql
---------------

you'll need `xcgd/postgresql`_ docker image::

  $ docker run --name="pg93" xcgd/postgresql

.. _xcgd/postgresql: https://registry.hub.docker.com/u/xcgd/postgresql/

Note: do not remove your container as your data volumes are bound to it.

Start Odoo
----------

Run your docker, assuming you named your postgresql docker pg93 as we did above::

  $ docker run -p 8069:8069 --rm --name="xcgd.odoo" --link pg93:db xcgd/odoo 


WARNING: note that we aliased the postgresl as ``db``. This is MANDATORY since we use this alias in the configuration files.

If docker starts without issues, just open your favorite browser and point it to http://localhost:8069

If you want to change the odoo configuration with you own file you can do so easily like so::

  # let's pretend your configuration is located under /opt/odoo/instance1/etc/ on your host machine, you can run it by

  docker run --name="xcgd.odoo" -v /opt/odoo/instance1/etc:/opt/odoo/etc -p 8069:8069 --link pg93:db -d xcgd/odoo

Security Notes
==============

You'll note that we did not open ports to the outside world on the PostgreSQL container. This is for security reasons, NEVER RUN your Postgresql container with ports open to the outside world... Just link the openerp container to it as we did above.

This is really important to understand. Posgtgresql is configured to trust everyone so better keep it firewalled. And before yelling madness please consider this: If someone gains access to your host and is able to launch a container and open a port for himself he's got your data anyways... he's on your machine. So keep that port closed and secure your host. You database is as safe as your host is, no more.
