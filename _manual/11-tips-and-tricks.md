---
chapter: 11
title: Tips & Tricks
---

The flex output allows a wide range of configuration options. Here
are some extra tips & tricks.

### Using `create_only` Columns for Postprocessed Data

Sometimes it is useful to have data in table rows that osm2pgsql can't create.
For instance you might want to store the center of polygons for faster
rendering of a label.

To do this define your table as usual and add an additional column, marking
it `create_only`. In our example case the type of the column should be the
PostgreSQL type `GEOMETRY(Point, 3857)`, because we don't want osm2pgsql to
do anything special here, just create the column with this type as is.

```lua
polygons_table = osm2pgsql.define_area_table('polygons', {
    { column = 'tags', type = 'hstore' },
    { column = 'geom', type = 'geometry' },
    { column = 'center', type = 'GEOMETRY(Point, 3857)', create_only = true },
    { column = 'area', type = 'area' },
})
```

After running osm2pgsql as usual, run the following SQL command:

```sql
UPDATE polygons SET center = ST_Centroid(geom) WHERE center IS NULL;
```

If you are updating the data using `osm2pgsql --append`, you have to do this
after each update. When osm2pgsql inserts new rows they will always have a
`NULL` value in `center`, the `WHERE` condition makes sure that we only do
this (possibly expensive) calculation once.

