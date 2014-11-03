A dockerfile for Odoo 7 & 8 & 9alpha
====================================

Odoo version
============

This docker builds with a specific version of odoo (formerly OpenERP) . We manually pin revisions our team has validated.
This is important to do in this way (as opposed to nightly builds) because we want to ensure reliability.
Here are the current revisions from https://github.com/odoo/odoo for each docker tag

    # production grade
    xcgd/odoo:7.0	df845940ed52040ef92b1b5759306c556fa38e66 (branch 7.0)
    xcgd/odoo:8.0	78f3b94601d7cc2939232d3ec58e63be965524b0 (branch 8.0)

    # playing only
    xcgd/odoo:latest	4df2e6dee377fc42e9021cb0c8f1c1e0e9b3772d (branch master/9alpha)

Prerequisites
=============

xcgd/postgresql
---------------

you'll need [xcgd/postgresql][1] docker image or any other postgresql image of your choice that you link with odoo under the name `db`:

    $ docker run --name="pg93" xcgd/postgresql

Note: do not remove your PostgreSQL container as your data volumes are bound to it.

Start Odoo
----------

Run your docker, assuming you named your postgresql docker pg93 as we did above:

    $ docker run -p 8069:8069 -p 8072:8072 --rm --name="xcgd.odoo" --link pg93:db xcgd/odoo:8.0 


WARNING: note that we aliased the postgresl as ``db``. This is MANDATORY since we use this alias in the configuration files.

If docker starts without issues, just open your favorite browser and point it to http://localhost:8069

If you want to change the odoo configuration with you own file you can do so easily like so: 

    # let's pretend your configuration is located under /opt/odoo/instance1/etc/ on your host machine, you can run it by

    docker run --name="xcgd.odoo" -v /opt/odoo/instance1/etc:/opt/odoo/etc -p 8069:8069 --link pg93:db -d xcgd/odoo


Security Notes
==============

You'll note that we did not open ports to the outside world on the PostgreSQL container. This is for security reasons, NEVER RUN your Postgresql container with ports open to the outside world... Just link the openerp container to it as we did above.

This is really important to understand. Posgtgresql is configured to trust everyone so better keep it firewalled. And before yelling madness please consider this: If someone gains access to your host and is able to launch a container and open a port for himself he's got your data anyways... he's on your machine. So keep that port closed and secure your host. You database is as safe as your host is, no more.


  [1]: https://registry.hub.docker.com/u/xcgd/postgresql/

