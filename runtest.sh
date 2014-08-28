#!/bin/bash

# this is what starts your ERP server
docker run -i -t -p 8069:8069 --rm -u root --volumes-from "xcgd.odoo" --link pg93:db xcgd/odoo /bin/bash
