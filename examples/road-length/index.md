---
layout: examples
title: Geospatial Analysis
---

*You need at least osm2pgsql version 1.7.0 for this example.*

An osm2pgsql database and PostGIS are well-suited for geospatial analysis using
OpenStreetMap data. PostGIS provides a [large number of geometry
functions](https://postgis.net/docs/manual-3.0/reference.html){:.extlink}
and a full description of how to perform analysis with them is beyond the
scope of this document, but a simple example of finding the total road lengths
by classification for a municipality shows the concepts.

To start with, we'll download the data for the region as an [extract from
Geofabrik](https://download.geofabrik.de/){:.extlink}. We could import all of
that data, but that's going to take a while. It is better to filter out only
what we need using [Osmium](https://osmcode.org/osmium-tool/){:.extlink}. In
this case these are the highway geometries and the administrative boundaries.

```sh
osmium tags-filter -v -o data.osm.pbf british-columbia-latest.osm.pbf w/highway r/boundary=administrative
```

We can now import the result with osm2pgsql into a database called `gis` that
we created beforehand:

```sh
osm2pgsql -d gis -O flex -S highways.lua data.osm.pbf
```

Here is the `highways.lua` config file we are using:

{% include download.html file="highways.lua" %}

```lua
{%- include_relative highways.lua -%}
```

Loading should take only a few seconds. Once this is done we'll open a
PostgreSQL terminal with `psql -d gis`, although a GUI like pgadmin or any
standard tool could be used instead.

We'll first find the ID of the polygon we want

```sql
SELECT area_id FROM boundaries
    WHERE tags->>'boundary' = 'administrative'
      AND tags->>'admin_level' = '8'
      AND tags->>'name' = 'New Westminster';
```

The result is this:

```
  osm_id
----------
 -1377803
```

The negative sign tells us that the geometry is from a relation, and checking
on [the OpenStreetMap
site](https://www.openstreetmap.org/relation/1377803){:.extlink} confirms that
it is.

We want to find all the roads in the city and get the length of the portion in
the city, sorted by road classification. Roads are in the `highways` table, the
administrative areas in the `boundaries` table:

```sql
WITH area_of_interest AS
  (SELECT geom FROM boundaries WHERE area_id=-1377803)
SELECT
    round(SUM(
      ST_Length(
        ST_Intersection(geom, (SELECT geom FROM area_of_interest))::geography
    ))) AS "length (meters)", type
  FROM highways
    WHERE ST_Intersects(geom, (SELECT geom FROM area_of_interest))
    GROUP BY type
    ORDER BY "length (meters)" DESC
    LIMIT 10;
```

The result is this table:

```
 length (meters) | type
-----------------+--------------
          118166 | residential
          106993 | service
           69912 | footway
           25540 | tertiary
           23180 | unclassified
           17407 | primary
           17075 | cycleway
           10502 | secondary
            7119 | path
            5306 | motorway
```

The cast `...::geography` is the easiest way to get the result in meters.

More complicated analysises can be done, but this simple example shows how
to use the tables and put conditions on the columns.

