#!/bin/bash

docker run -d -p 8069:8069 --rm --name="xcgd.odoo" -v `pwd`/etc:/opt/openerp/etc -v `pwd`/other-addons:/opt/openerp/additionnal_addons -v `pwd`/var:/opt/openerp/var -v `pwd`/other-addons:/opt/openerp/additionnal_addons xcgd/odoo
