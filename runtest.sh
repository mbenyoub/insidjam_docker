#!/bin/bash

# this is what starts an interactive shell within your container
docker run -ti --rm --volumes-from "odoo8" --link pg93:db xcgd/odoo /bin/bash
