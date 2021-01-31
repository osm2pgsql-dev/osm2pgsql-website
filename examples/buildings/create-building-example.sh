#!/bin/sh

wget https://download.geofabrik.de/south-america/brazil/centro-oeste-latest.osm.pbf

wget -O federal-district.osm https://www.openstreetmap.org/api/0.6/relation/421151/full

osmium extract -p federal-district.osm -o brasilia.osm.pbf centro-oeste-latest.osm.pbf

osm2pgsql -d mbuildings -O flex -S buildings.lua brasilia.osm.pbf

psql mbuildings -c "CREATE UNIQUE INDEX ON buildings (id);"

