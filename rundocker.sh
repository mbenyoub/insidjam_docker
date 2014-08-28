#!/bin/bash

# this is what starts your ERP server
docker run -p 8069:8069 --name="xcgd.odoo" --link pg93:db xcgd/odoo
