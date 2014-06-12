How to
======

Install docker
--------------

Just install docker using `their documentation`_

  .. _their documentation: https://docs.docker.com/

Grab your copy of xcgd/odoo
---------------------------

::
  $ docker pull xcgd/odoo

Setup your config
-----------------

This directory is an example layout that you'll need to run you dockerized Odoo.
An example odoo config file is provided inside the etc/ directory. You'll need to edit
it and set proper values for your deployment options.

It is fully commented so it is quite easy to get it working

Run
---

When you're done editing the configuration file just run::

  $ ./rundocker.sh

Inspect the logfiles
--------------------

When it is started you can easily::

  $ tail -d var/log/openerp/openerp.log

To see what's going on.
