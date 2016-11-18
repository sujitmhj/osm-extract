# osm-extract
A script that allows to download data from OpenStreetMap for a country of interest, perform ETL procedures in order to classify data into layers and publish it in a PostgreSQL+PostGIS database.
It is based on a fork from Terronodo and it is built around a Makefile with instructions that must be executed with the Linux make command.
Once OSM data have been loaded into PostGIS, they can be published in GeoNode. 
In addition data can be updated on a fixed frequency, by executing the Makefile with a scheduled cron job. In such case a sql instruction can be executed in order to update the publication date of the respective metadata published by GeoNode.

# Steps for putting it in production
1.	Download the repo
2.	Install the dependencies: osmosis. (GeoNode  is assumed to be up and running)
3.	Launch the Makefile for the first time
4.	Publish the layers in GeoNode, update_layers
5.	Customize the sh file
6.	Schedule the shell file as a cron job
