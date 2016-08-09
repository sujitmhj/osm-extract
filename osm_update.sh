#!/bin/bash

export PATH=$PATH:/opt/osmosis/bin
cd /home/ubuntu/osm-extract
echo $(date)
make all NAME=malawi URL="http://download.openstreetmap.fr/extracts/africa/malawi-latest.osm.pbf" && psql -d geonode -f set_pub_date.sql
echo $(date)
