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


Running an instance
===================

To run an instance you'll need to prepare a configuration file for odoo on your host filesystem and to pass it to your docker::

  $ mkdir etc
  $ cp <myopenerp-configfile.conf> etc/openerp.conf


create the necessary ``var`` structure for our log files, unix sockets and pid files::

  $ mkdir -p var/log && mkdir -p var/run && mkdir var/supervisor

 
Finally run your docker::

  $ docker run -d -p 8069:8069 --name="odoo" -v `pwd`/etc:/opt/openerp/etc -v `pwd`/var:/opt/openerp/var xcgd/odoo

This means that the odoo process will read your config file and use the configuration details to connect to the database server. So don't forget to put a real IP address reachable by the docker (ie: NOT 127.0.0.1 or localhost) for the database server entry.

If something happend try to remove the ``-d`` flag from the command line to see the output on your console::

  $ docker run -p 8069:8069 --name="odoo" -v `pwd`/etc:/opt/openerp/etc -v `pwd`/var:/opt/openerp/var xcgd/odoo

If docker starts without issues, just open your favorite browser and point it to http://localhost:8069
