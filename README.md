A dockerfile for Odoo 7 & 8 & 9alpha
====================================

!!!Latest changes!!!
====================
This image has been "applified" and behaves just like a binary application with several options.

Try running ```docker run --rm xcgd/odoo``` and see what happens :)

Check the [BitBucket project page][2] for contributing, discussing and reporting issues.
This README is updated with regards to your questions. Thank you for your help!

NB: the volume /opt/odoo/additional_addons has been renamed to fix a typo (courtesy of @blaggacao)

Odoo version
============

This docker builds with a specific version of odoo (formerly OpenERP) . We manually pin revisions our team has validated.
This is important to do in this way (as opposed to nightly builds) because we want to ensure reliability.

You may use your own sources simply by binding your local odoo folder to /opt/odoo/sources/odoo/

Here are the current revisions from https://github.com/odoo/odoo for each docker tag

    # production grade
    xcgd/odoo:7.0	1adb3de371949866acbb1225e3bc5cdbab2d2fac (branch 7.0)
    xcgd/odoo:8.0	faee926f1bc8c5cc356cd45dc6f8b675f79984f2 (branch 8.0)

    # playing only
    xcgd/odoo:latest	660b13bb7819fe3212bdf9fe450297b2852169ff (branch master/9alpha)

Prerequisites
=============

xcgd/postgresql
---------------

you'll need [xcgd/postgresql][1] docker image or any other PostgreSQL image of your choice that you link with odoo under the name `db`:

    $ docker run --name="pg93" xcgd/postgresql

Note: read the instructions on how to use this image with data persistance.

Start Odoo
----------

Run odoo version 7.0, assuming you named your PostgreSQL container ``pg93`` as we did above:

    $ docker run -p 8069:8069 --rm --name="xcgd.odoo" --link pg93:db xcgd/odoo:7.0 start


WARNING: note that we aliased the PostgreSQL as ``db``. This is ARBITRARY since we use this alias in the configuration files.

If docker starts without issues, just open your favorite browser and point it to http://localhost:8069	

The default admin password is somesuperstrongadminpasswdYOUNEEDTOCHANGEBEFORERUNNING

If you want to change the odoo configuration with you own file you can do so easily like so: 

    # let's pretend your configuration is located under /opt/odoo/instance1/etc/ on your host machine, you can run it by

    $ docker run --name="xcgd.odoo" -v /opt/odoo/instance1/etc:/opt/odoo/etc -p 8069:8069 --link pg93:db -d xcgd/odoo start


Security Notes
==============

You'll note that we did not open ports to the outside world on the PostgreSQL container. This is for security reasons, NEVER RUN your PostgreSQL container with ports open to the outside world... Just *--link* the openerp container to it as we did above.

This is really important to understand. PostgreSQL is configured to trust everyone so better keep it firewalled. And before yelling madness please consider this: If someone gains access to your host and is able to launch a container and open a port for himself he's got your data anyways... he's on your machine. So keep that port closed and secure your host. You database is as safe as your host is, no more.


  [1]: https://registry.hub.docker.com/u/xcgd/postgresql/
  [2]: https://bitbucket.org/xcgd/odoo
