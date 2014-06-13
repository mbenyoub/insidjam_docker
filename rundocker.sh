#!/bin/bash

# this is usefull for first time run... can be commented out for all the others
docker run --rm --volumes-from odoo_data -u root xcgd/odoo /bin/bash /opt/openerp/var/takeownership.sh

# this is what starts your ERP server
docker run -p 8069:8069 --rm --name="xcgd.odoo" --link pg93:db --volumes-from odoo_data xcgd/odoo
