#!/bin/bash
docker build --rm -t xcgd/odoo:$(hg identify -b) .

