# osm-extract
A script that allows to download data from OpenStreetMap for a country of interest, perform ETL procedures in order to classify data into layers and publish it in a PostgreSQL+PostGIS database.
It is based on a fork from Terronodo and it is built around a Makefile with instructions that must be executed with the Linux make command (we assume you are working on a Linux based OS).
Once OSM data have been loaded into PostGIS, they can be published in GeoNode. 
In addition data can be updated on a fixed frequency, by executing the Makefile with a scheduled cron job. In such case a sql instruction can be executed in order to update the publication date of the respective metadata published by GeoNode.

# Steps for putting it in production
1. Download the repo
2. Install the dependencies: osmosis. (GeoNode  is assumed to be up and running)
3. Launch the Makefile for the first time
4. Publish the layers in GeoNode, update_layers
5. Customize the sh file
6. Customize the SQL file 
7. Schedule the shell file as a cron job

## 1. Download the repo
`git clone https://github.com/MalawiGeospatialTools/osm-extract.git`

## 2. Install the dependencies
We assume that GeoNode is already installed on your machine.
In addition to that you need to install osmosis, which is used by the Makefile to handle OSM data.
In order to do so, follow the instructions at [Installing pre-built Osmosis] (http://wiki.openstreetmap.org/wiki/Osmosis/Installation#Linux)

## 3. Launch the Makefile for the first time
Set the current directory to the directory where the Makefile is stored.
Then launch it by typing the following command:
`make all NAME=<country> URL="<Planet.osm mirror>"`
Substitute in the command `<country>` with the name of your country of interesest (e.g. `malawi`); and `<Planet.osm mirror>` with one of the mirrors listed in (http://wiki.openstreetmap.org/wiki/Planet.osm#Downloading).
The procedure is going to create a new database in your PostgreSQL instance and store in it the OSM data for your country. Therefore you should run the Makefile with a user that has enough privileges.

## 4. Publish the layers in GeoNode
We propose to do so in two steps: firstly publish the layers in GeoServer and then in GeoNode. 
In GeoServer generate a new Workspace so that you can keep it separate from the default GeoNode Workspace. Then create a new Store in it and publish the layers of your interest from the ones that were created by the procedure at the previous step (please note that some of them may be empty, depending on the countries of interest).
In GeoNode take advantage of the updatelayers command and publish all layers from the GeoServer Workspace created ad-hoc at the previous step. See the [GeoNode documentation]( http://docs.geonode.org/en/master/tutorials/admin/admin_mgmt_commands/) for details.

## 5. Customize the sh file
Customize the osm_update.sh file in order to fit your server and software configuration, namely:
* define the installation path (on line 3) for the osmosis software, so that it can be found by the OS
* change the current directory to a working directory of your interest, where temporary files can be stored, deleted and updated (on line 4)
* define the name of the country of interest as well as the url (on line 6) as you did in step 3

## 6. Customize the SQL file
Customize the set_pub_date.sql file in order to fit it for your purpose. In particular substitute the store name `osm_extracts` with the name of the store in which your OSM data are in GeoServer.

## 7. Schedule the shell file as a cron job
Insert the osm_update.sh file in the crontab of your server as a scheduled job. In order to do so, please have a look at the official cron documentation. If you’re using Ubuntu OS, please have a look [here](https://help.ubuntu.com/community/CronHowto).
