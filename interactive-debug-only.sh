#!/bin/bash

docker run -i -t --rm -u="root" --volumes-from "xcgd.odoo" xcgd/odoo bash
