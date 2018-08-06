#!/bin/bash

NAME=nepal

cd /usr/src/osm-extract
echo $(date)
make all NAME=$NAME URL="http://download.geofabrik.de/asia/nepal-latest.osm.pbf" && psql -d npl_geo -f set_pub_date.sql
echo $(date)
rm -rf $NAME/*.pbf
rm -rf $NAME/*.sql
