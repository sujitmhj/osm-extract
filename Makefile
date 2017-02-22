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

built_up_areas.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-ways landuse=residential,allotments,cemetery,construction,depot,garages,brownfield,commercial,industrial,retail --used-node --write-pbf file="$(NAME)/$@"

cities.pbf: all_places.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=city" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

farms.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.farm,landuse.farmland,landuse.farmyard,landuse.livestock" --used-node --write-pbf file="$(NAME)/$@"

forest.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.forest,natural.wood" --used-node --write-pbf file="$(NAME)/$@"

grassland.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="landuse.grass,landuse.meadow,landuse.scrub,landuse.village_green,natural.scrub,natural.heath,natural.grassland" --used-node --write-pbf file="$(NAME)/$@"

helipads.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes aeroway=helipad,heliport --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

hotels.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="tourism.hotel,tourism.hostel,tourism.motel,tourism.guest_house" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

inland_water_line.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" \
	--tf reject-nodes --tf reject-relations --tf accept-ways waterway=* \
	--write-pbf file="$(NAME)/$@"

inland_water_polygon.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" \
	--tf accept-ways natural=water,wetland,bay landuse=reservoir,basin,salt_pond waterway=river,riverbank \
	--tf accept-relations natural=water,wetland,bay landuse=reservoir,basin,salt_pond waterway=river,riverbank \
	--tf reject-nodes \
	--write-pbf file="$(NAME)/$@"

main_roads.pbf: all_roads.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.motorway,highway.trunk,highway.primary" --used-node --write-pbf file="$(NAME)/$@"

medical_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.baby_hatch,amenity.clinic,amenity.dentist,amenity.doctors,amenity.hospital,amenity.nursing_home,amenity.pharmacy,amenity.social_facility,amenity.veterinary,amenity.blood_donation" --write-pbf file="$(NAME)/$@"

medical_polygon.pbf: buildings.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="amenity.baby_hatch,amenity.clinic,amenity.dentist,amenity.doctors,amenity.hospital,amenity.nursing_home,amenity.pharmacy,amenity.social_facility,amenity.veterinary,amenity.blood_donation" --used-node --write-pbf file="$(NAME)/$@"

paths.pbf: all_roads.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="highway.footway,highway.bridleway,highway.steps,highway.path" --used-node  --write-pbf file="$(NAME)/$@"

police_stations.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.police" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

railways.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-ways "railway=*" --used-node --write-pbf file="$(NAME)/$@"

schools_point.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.school,amenity.university,amenity.college,amenity.kindergarten" --write-pbf file="$(NAME)/$@"

schools_polygon.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --wkv keyValueList="amenity.school,amenity.university,amenity.college,amenity.kindergarten" --used-node --write-pbf file="$(NAME)/$@"

towns.pbf: all_places.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=town" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

villages.pbf: all_places.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --tf accept-nodes "place=village" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"

tracks.pbf: all_roads.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<"  --wkv keyValueList="highway.track" --used-node --write-pbf file="$(NAME)/$@"

#restaurants.pbf: latest.pbf
#	osmosis --read-pbf-fast file="$(NAME)/$<" --nkv keyValueList="amenity.restaurant,amenity.restaurants" --tf reject-ways --tf reject-relations --write-pbf file="$(NAME)/$@"
#
train_stations.pbf: latest.pbf
	osmosis --read-pbf-fast file="$(NAME)/$<" --tf accept-nodes "railway=station" --tf reject-ways --tf reject-relations  --write-pbf file="$(NAME)/$@"

SQL_EXPORTS = buildings.sql schools_point.sql schools_polygon.sql medical_point.sql medical_polygon.sql rivers.sql railways.sql inland_water_polygon.sql farms.sql forest.sql grassland.sql built_up_areas.sql all_places.sql cities.sql towns.sql villages.sql all_roads.sql main_roads.sql paths.sql tracks.sql aerodromes_point.sql aerodromes_polygon.sql banks.sql  hotels.sql police_stations.sql train_stations.sql helipads.sql

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
