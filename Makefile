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
SETNAME=$(NAME)

mk-work-dir:
	mkdir -p ./$(NAME)

latest.pbf: mk-work-dir
	curl -g -o $(NAME)/$@.temp $(URL)
	if file $(NAME)/$@.temp | grep XML; then \
        osmosis --read-xml file="$(NAME)/$@.temp" --write-pbf file="$(NAME)/$@"; \
    else \
        mv $(NAME)/$@.temp $(NAME)/$@; \
    fi

aerodromes_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="aeroway.aerodrome" --write-pbf file="$(NAME)/$@"

aerodromes_polygon.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --wkv keyValueList="aeroway.aerodrome" --used-node --write-pbf file="$(NAME)/$@"

all_places.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="place.city,place.borough,place.suburb,place.quarter,place.neighbourhood,place.city_block,place.plot,place.town,place.village,place.hamlet,place.isolated_dwelling,place.farm,place.allotments" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

all_roads.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "highway=*" --used-node --write-pbf file="$(NAME)/$@"

banks.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes amenity=bank,atm,bureau_de_change --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

buildings.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "building=*"  --write-pbf file="$(NAME)/$@"

farms.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.farm,landuse.farmland,landuse.farmyard,landuse.livestock" --used-node --write-pbf file="$(NAME)/$@"

forest.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.forest,natural.wood" --used-node --write-pbf file="$(NAME)/$@"

grassland.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.grass,landuse.meadow,landuse.scrub,landuse.village_green,natural.scrub,natural.heath,natural.grassland" --used-node --write-pbf file="$(NAME)/$@"

schools_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.school,amenity.university,amenity.college,amenity.kindergarten" --write-pbf file="$(NAME)/$@"

schools_polygon.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="amenity.school,amenity.university,amenity.college,amenity.kindergarten" --used-node --write-pbf file="$(NAME)/$@"

medical_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.hospital,amenity.doctors,amenity.doctor,amenity.clinic,amenity.health_post" --write-pbf file="$(NAME)/$@"

medical_polygon.pbf: buildings.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="amenity.hospital,amenity.doctors,amenity.doctor,amenity.clinic,amenity.health_post" --used-node --write-pbf file="$(NAME)/$@"

rivers.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="waterway.river,waterway.stream,waterway.ditch" --used-node --write-pbf file="$(NAME)/$@"

lakes.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="natural.water,water.lake" --used-node --write-pbf file="$(NAME)/$@"

# removed because empty
#military.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=military" --used-node --write-pbf file="$(NAME)/$@"
#
# commented out because not extracted at the moment
#orchards.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=orchard" --used-node --write-pbf file="$(NAME)/$@"

railways.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-ways "railway=*" --used-node --write-pbf file="$(NAME)/$@"

residential.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-ways "landuse=residential" --used-node --write-pbf file="$(NAME)/$@"

# commented out because not extracted currently
#village_green.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=village_green" --used-node --write-pbf file="$(NAME)/$@"
#
# not extracted at the moment
#wetlands.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-ways "landuse=wetland" --used-node --write-pbf file="$(NAME)/$@"

cities.pbf: all_places.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=city" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

towns.pbf: all_places.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=town" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

#neighborhoods.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="place.neighborhood,place.neighbourhood" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

villages.pbf: all_places.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=village" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

#placenames.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="place.city,place.hamlet,place.neighborhood,place.neighbourhood,place.village" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

#all_roads.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.unclassified,highway.tertiary,highway.residential,highway.service,highway.secondary,highway.track,highway.footway,highway.path,highway.classified,highway.primary,highway.trunk,highway.motorway,highway.construction,highway.proposed,highway.cycleway,highway.living_street,highway.steps,highway.road,highway.pedestrian,highway.construction,highway.bridleway,highway.platformhighway.proposed" --used-node --write-pbf file="$(NAME)/$@"

main_roads.pbf: all_roads.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.motorway,highway.trunk,highway.primary" --used-node --write-pbf file="$(NAME)/$@"

paths.pbf: all_roads.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.footway,highway.bridleway,highway.steps,highway.path" --used-node  --write-pbf file="$(NAME)/$@"

tracks.pbf: all_roads.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --wkv keyValueList="highway.track" --used-node --write-pbf file="$(NAME)/$@"

# commented out because non extracted at the moment
#fire_stations.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes "amenity=fire_station" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"
#
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

SQL_EXPORTS = buildings.sql schools_point.sql schools_polygon.sql medical_point.sql medical_polygon.sql rivers.sql railways.sql lakes.sql farms.sql forest.sql grassland.sql residential.sql all_places.sql cities.sql towns.sql villages.sql all_roads.sql main_roads.sql paths.sql tracks.sql aerodromes_point.sql aerodromes_polygon.sql banks.sql  hotels.sql police_stations.sql restaurants.sql train_stations.sql helipads.sql

PBF_EXPORTS = $(SQL_EXPORTS:.sql=.pbf)
POSTGIS_EXPORTS = $(SQL_EXPORTS:.sql=.postgis)

%.sql: %.pbf
	ogr2ogr -f PGDump $(NAME)/$@ $(NAME)/$< -lco COLUMN_TYPES=other_tags=hstore --config OSM_CONFIG_FILE conf/$(basename $@).ini

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

all: createdb $(PBF_EXPORTS) $(SQL_EXPORTS) $(POSTGIS_EXPORTS)

postgis: $(POSTGIS_EXPORTS)

.PHONY: clean
clean:
	rm -rf $(NAME)/*.pbf
	rm -rf $(NAME)/*.sql
	if psql -lqt | cut -d \| -f 1 | grep -w $(DB); then \
		psql -f conf/clean.sql -q $(DB); \
	fi
