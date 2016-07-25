#!/bin/bash

export PATH=$PATH:/opt/osmosis/bin
cd /home/ubuntu/osm-extract
make all NAME=malawi URL="http://download.openstreetmap.fr/extracts/africa/malawi-latest.osm.pbf"

