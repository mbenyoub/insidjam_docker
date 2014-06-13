#!/bin/bash

pip wheel --allow-external pydot --allow-unverified pydot "pydot==1.0.28"
pip wheel -r wheelstobuild.txt
