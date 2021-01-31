#!/bin/sh

wget https://download.geofabrik.de/europe/belgium-latest.osm.pbf

osmium extract -b 4.29,50.815,4.47,50.90 belgium-latest.osm.pbf -o brussels.osm.pbf

osm2pgsql -d brussels -O flex -S streets.lua brussels.osm.pbf

