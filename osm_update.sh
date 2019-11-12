#!/bin/bash

NAME=nepal

cd /opt/osm-extract/osm-extract
echo $(date)
make all NAME=$NAME URL="http://download.geofabrik.de/asia/nepal-latest.osm.pbf" && psql -U geonode -h localhost -d nepal_osm -f set_pub_date.sql
echo $(date)
rm -rf $NAME/*.pbfs
rm -rf $NAME/*.sql
