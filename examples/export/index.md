---
layout: examples
title: Exporting OSM Data
---

Osm2pgsql can be used in combination with
[ogr2ogr](https://gdal.org/programs/ogr2ogr.html){:.extlink} (using the
[PostgreSQL data source](https://gdal.org/drivers/vector/pg.html){:.extlink})
to first import OSM data into a database, possible clean it up or reformat it
and then export it again into about any [GIS vector
format](https://gdal.org/drivers/vector/index.html){:.extlink} there is.

For this use case we can run osm2pgsql with the flex output and the
[generic.lua](https://github.com/openstreetmap/osm2pgsql/blob/master/flex-config/generic.lua)
configuration. This imports most of the OSM data into the database using
convenient `jsonb` columns for the tags:

```sh
osm2pgsql -d osm -O flex -S flex-config/generic.lua OSMDATA.osm.pbf
```

Now we can use the `psql` command or other database tools to create SQL views
to access exactly the data we want. Lets get all the ways tagged `highway`:

```sql
CREATE OR REPLACE VIEW highways AS
    SELECT way_id, geom, tags->>'highway' AS type, tags->>'name' AS name
        FROM lines WHERE tags ? 'highway';
```

To verify you are getting the correct data, you can use
[QGIS](https://qgis.org){:.extlink} for instance.

An example command to export this to GeoJSON would be:

```sh
ogr2ogr -f "GeoJSON" highways.geojson PG:"dbname=osm" highways
```

We can do all sorts of processing either inside the Lua script or in the
database to wrangle the data into the format we need. Here is another example:
In OSM points of interest can either be mapped as nodes or as areas. Lets
get all the restaurants tagged as nodes:

```sql
CREATE OR REPLACE VIEW restaurant_nodes AS
    SELECT node_id, geom, tags->>'name' AS name
        FROM points WHERE tags->>'amenity' = 'restaurant';
```

And now all the areas:

```sql
CREATE OR REPLACE VIEW restaurant_areas AS
    SELECT area_id, geom, tags->>'name' AS name
        FROM polygons WHERE tags->>'amenity' = 'restaurant';
```

And now combine these into one view with just the center points for areas:

```sql
CREATE OR REPLACE VIEW restaurants AS
    SELECT (2 * node_id) AS id, geom, name FROM restaurant_nodes
    UNION
    SELECT (2 * area_id + 1) AS id, ST_Centroid(geom) AS geom, name FROM restaurant_areas;
```

The fancy calculations for the `id` are there to generate a guaranteed unique
id, because lots of programs like QGIS expect a unique id column.

This time we dump these into a
[Shapefile](https://en.wikipedia.org/wiki/Shapefile){:.extlink}:

```sh
ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 restaurants.shp PG:"dbname=osm" restaurants
```

Note that we are setting the output encoding to UTF-8, because OSM tags use
UTF-8 encoding and Shapefiles by default do not.

Exporting the data to a CSV file is also possible. Start `psql` and type:

```sql
\copy (SELECT ST_X(geom) AS lon, ST_Y(geom) AS lat, name FROM restaurants) TO 'restaurants.csv' WITH csv header;
```

Once you get used to this kind of operation you don't always need to create
the views, but can do this in one step specifying an SQL query on the command
line:

```sh
ogr2ogr -f "GeoJSON" water.geojson PG:"dbname=osm" \
    -sql "SELECT geom, tags->>'name' FROM polygons WHERE tags->>'natural' = 'water'"
```

