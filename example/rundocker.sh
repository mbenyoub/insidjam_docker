#!/bin/bash

docker run -p 8069:8069 --rm --name="xcgd.odoo" --link pg93:db -v `pwd`/etc:/opt/openerp/etc -v `pwd`/other-addons:/opt/openerp/additionnal_addons -v `pwd`/var:/opt/openerp/var -v `pwd`/other-addons:/opt/openerp/additionnal_addons xcgd/odoo
