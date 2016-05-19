# Install gdal 1.10 or newer and compile using the following:
# ./configure --with-spatialite=yes --with-expat=yes --with-python=yes
# Without it, the OSM format will not be enabled.

# Install latest osmosis to get the read-pbf-fast command. older versions
# like the one shipped with Ubuntu 14.04 do not have this option.

# Once you have them, make sure gdal/apps and osmosis/bin are added to our path before running this file.
ifeq ($(URL),)
abort:
	@echo Variable URL not set && false
endif

ifeq ($(NAME),)
abort:
	@echo Variable NAME not set && false
endif

DB=$(NAME)_osm
EXPORT_DIR=/var/www/html/$(NAME)/data

mk-work-dir:
	mkdir -p ./$(NAME)

latest.pbf: mk-work-dir
	curl -g -o $(NAME)/$@.temp $(URL)
	if file $(NAME)/$@.temp | grep XML; then \
        osmosis --read-xml file="$(NAME)/$@.temp" --write-pbf file="$(NAME)/$@"; \
    else \
        mv $(NAME)/$@.temp $(NAME)/$@; \
    fi    

buildings.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "building=*"  --write-pbf file="$(NAME)/$@"

bridges.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "bridge=*"  --write-pbf file="$(NAME)/$@"

idp_camps.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="idp:camp_site=spontaneous_camp,damage:event.dominica_earthquake_2015" --used-node  --write-pbf  file="$(NAME)/$@"

huts.pbf: buildings.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-ways "building=hut" --used-node --write-pbf file="$(NAME)/$@"

trees.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes "natural=tree" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

schools_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.school,amenity.university,amenity.college,amenity.kindergarten" --write-pbf file="$(NAME)/$@"

schools_polygon.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="amenity.school,amenity.university,amenity.college,amenity.kindergarten" --used-node --write-pbf file="$(NAME)/$@"

medical_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.hospital,amenity.doctors,amenity.doctor,amenity.clinic,amenity.health_post" --write-pbf file="$(NAME)/$@"

medical_polygon.pbf: buildings.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="amenity.hospital,amenity.doctors,amenity.doctor,amenity.clinic,amenity.health_post" --used-node --write-pbf file="$(NAME)/$@"
  
roads.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "highway=*" --used-node --write-pbf file="$(NAME)/$@"

rivers.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="waterway.river,waterway.stream,waterway.ditch" --used-node --write-pbf file="$(NAME)/$@"
  
riverbanks.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="waterway.riverbank" --used-node --write-pbf file="$(NAME)/$@"

lakes.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="natural.water,water.lake" --used-node --write-pbf file="$(NAME)/$@"
 
beaches.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="natural.beach" --used-node --write-pbf file="$(NAME)/$@"

farms.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.farm,landuse.farmland,landuse.farmyard" --used-node --write-pbf file="$(NAME)/$@"
 
forest.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.forest" --used-node --write-pbf file="$(NAME)/$@"
 
grassland.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.grass,landuse.grassland,natural.wood,natural.grassland" --used-node --write-pbf file="$(NAME)/$@"
 
military.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=military" --used-node --write-pbf file="$(NAME)/$@"
 
orchards.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=orchard" --used-node --write-pbf file="$(NAME)/$@"

residential.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=residential" --used-node --write-pbf file="$(NAME)/$@"

village_green.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=village_green" --used-node --write-pbf file="$(NAME)/$@"

wetlands.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=wetland" --used-node --write-pbf file="$(NAME)/$@"

cities.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=city" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

hamlets.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=hamlet" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

neighborhoods.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="place.neighborhood,place.neighbourhood" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

villages.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=village" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

placenames.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="place.city,place.hamlet,place.neighborhood,place.neighbourhood,place.village" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

all_roads.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.unclassified,highway.tertiary,highway.residential,highway.service,highway.secondary,highway.track,highway.footway,highway.path,highway.classified,highway.primary,highway.trunk,highway.motorway,highway.construction,highway.proposed,highway.cycleway,highway.living_street,highway.steps,highway.road,highway.pedestrian,highway.construction,highway.bridleway,highway.platformhighway.proposed" --used-node --write-pbf file="$(NAME)/$@"

main_roads.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.motorway,highway.trunk,highway.primary" --used-node --write-pbf file="$(NAME)/$@"

paths.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.path,highway.trunk,highway.primary" --used-node  --write-pbf file="$(NAME)/$@"

tracks.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --wkv keyValueList="highway.track" --used-node --write-pbf file="$(NAME)/$@"

aerodromes_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="aeroway.aerodrome,aeroway.international" --write-pbf file="$(NAME)/$@"

aerodromes_polygon.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --wkv keyValueList="aeroway.aerodrome,aeroway.international" --used-node --write-pbf file="$(NAME)/$@"

banks.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes "amenity=bank" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

fire_stations.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes "amenity=fire_station" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

hotels.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="tourism.hotel,amenity.hotel" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

police_stations.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.police,tourism.police" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

restaurants.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.restaurant,amenity.restaurants" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

train_stations.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes "railway=station" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

helipads.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="aeroway.helipad" --used-node --write-pbf file="$(NAME)/$@"

SQL_EXPORTS = buildings.sql schools_point.sql schools_polygon.sql medical_point.sql medical_polygon.sql rivers.sql riverbanks.sql lakes.sql farms.sql forest.sql grassland.sql military.sql orchards.sql residential.sql cities.sql hamlets.sql neighborhoods.sql villages.sql placenames.sql all_roads.sql main_roads.sql paths.sql tracks.sql aerodromes_point.sql aerodromes_polygon.sql banks.sql  hotels.sql police_stations.sql restaurants.sql train_stations.sql helipads.sql

EXPORTS = $(SQL_EXPORTS:.sql=)
PBF_EXPORTS = $(SQL_EXPORTS:.sql=.pbf)
POSTGIS_EXPORTS = $(SQL_EXPORTS:.sql=.postgis)
SQL_ZIP_EXPORTS = $(SQL_EXPORTS:.sql=.sql.zip)
SHP_ZIP_EXPORTS = $(SQL_EXPORTS:.sql=.shp.zip)
GEOJSON_EXPORTS = $(SQL_EXPORTS:.sql=.json)
KML_EXPORTS = $(SQL_EXPORTS:.sql=.kml)

%.sql: %.pbf
	ogr2ogr -f PGDump $(NAME)/$@ $(NAME)/$< -lco COLUMN_TYPES=other_tags=hstore --config OSM_CONFIG_FILE conf/$(basename $@).ini

%.shp: %.postgis
	pgsql2shp -f $(NAME)/$(basename $@) $(DB) public.$(basename $<)

%.json: %.shp
	ogr2ogr -f GeoJSON -t_srs crs:84 $(NAME)/$@ $(NAME)/$<

%.kml: %.shp
	ogr2ogr -f KML -t_srs crs:84 $(NAME)/$@ $(NAME)/$<

%.shp.zip: %.shp
	zip $(NAME)/$@ $(NAME)/$< $(NAME)/$(basename $<).prj  $(NAME)/$(basename $<).dbf $(NAME)/$(basename $<).shx

%.sql.zip: %.sql
	zip $(NAME)/$@ $(NAME)/$<

%.postgis: %.sql
	psql -f $(NAME)/$< $(DB)
	psql -f conf/$(basename $@)_alter.sql $(DB)
	psql -f conf/clean.sql -q $(DB)

.PHONY: createdb
createdb:
	if psql -lqt | cut -d \| -f 1 | grep -w $(DB); then \
		echo "Database exists"; \
	else \
		createdb $(DB); \
		psql -d $(DB) -c 'create extension postgis;'; \
		psql -d $(DB) -c 'create extension hstore;'; \
	fi

all: createdb $(PBF_EXPORTS) $(SQL_EXPORTS) $(SQL_ZIP_EXPORTS) $(SHP_ZIP_EXPORTS) $(GEOJSON_EXPORTS) $(KML_EXPORTS) stats.js mapproxy
	cp index.html $(NAME)/
	sed -i .bk -e 's/Fiji/$(NAME)/' $(NAME)/index.html
	rm $(NAME)/index.html.bk

postgis: $(POSTGIS_EXPORTS)

stats.js: 
	python stats.py --name="$(NAME)" --files="$(EXPORTS)" >> $(NAME)/$@

.PHONY:
mapproxy:
	cp mapnik.xml $(NAME)/
	cp mapproxy.yaml $(NAME)/
	sed -i .bk -e 's/REPLACEME/$(NAME)/' $(NAME)/mapnik.xml
	sed -i .bk -e 's/REPLACEME/$(NAME)/' $(NAME)/mapproxy.yaml

.PHONY: clean
clean:
	rm -rf $(NAME)/*.pbf
	rm -rf $(NAME)/*.zip
	rm -rf $(NAME)/*.sql
	rm -rf $(NAME)/*.shp
	rm -rf $(NAME)/*.dbf
	rm -rf $(NAME)/*.shx
	rm -rf $(NAME)/*.prj
	rm -rf $(NAME)/*.json
	rm -rf $(NAME)/*.kml
	rm -rf $(NAME)/*.cpg
	rm -rf $(NAME)/stats.js
	if psql -lqt | cut -d \| -f 1 | grep -w $(DB); then \
		psql -f conf/clean.sql -q $(DB); \
	fi
