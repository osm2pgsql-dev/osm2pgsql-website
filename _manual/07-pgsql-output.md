---
chapter: 7
title: The Pgsql Output
---

This chapter is incomplete.
{:.wip}

The pgsql output is the original output osm2pgsql started with. It was designed
for rendering OpenStreetMap data, principally with Mapnik. It is still widely
used although it is somewhat limited in how the data can be represented in
the database.

If you are starting a new project with osm2pgsql, we recommend you use the
[flex output](#the-flex-output) instead. The pgsql output will not receive
all the new features that the flex output has or will get in the future.
(There are a lot of old configs and styles out there that need the pgsql
output, though. So it will not go away anytime soon.)
{: .note}

### Database Layout

The pgsql output always creates a fixed list of four tables shown in the
following table. The `PREFIX` can be set with the `-p, --prefix` option, the
default is `planet_osm`.

| Table          | Description |
| -------------- | --- |
| PREFIX_point   | Point geometries created from nodes. |
| PREFIX_line    | Line geometries created from ways and relations tagged `type=route`. |
| PREFIX_roads   | Contains some of the same data as the `line` table, but with attributes selected for low-zoom rendering. It does not only contain roads! |
| PREFIX_polygon | Polygon geometries created from closed ways and relations tagged `type=multipolygon` or `type=boundary`. |
{: .desc}

All tables contain a geometry column named `way` (which is not the most
intuitive name, but it can't be changed now because of backwards
compatibility).

### Style file

Some aspects of how the pgsql output converts OSM data into PostgreSQL tables
can be configured via a style file. The [default style
file](https://github.com/openstreetmap/osm2pgsql/blob/master/default.style)
that is usually installed with osm2pgsql is suitable for rendering the standard
OSM Mapnik style or similar styles. It also contains the documentation of the
style syntax. With a custom style file, you can control how different object
types and tags map to different columns and data types in the database.

The style file is a plain text file containing four columns separated by
spaces. As each OSM object is processed it is checked against conditions
specified in the first two columns. If they match, processing options from the
third and fourth columns are applied.

| Column                  | Description |
| ----------------------- | --- |
| 1. OSM object type      | Can be `node`, `way` or both separated by a comma. `way` will also apply to relations with `type=multipolygon`, `type=boundary`, or `type=route`; all other relations are ignored. |
| 2. Tag                  | The tag to match on. If the fourth column is `linear` or `polygon`, a column for this tag will be created in each of the point, line, polygon, and road tables. |
| 3. PostgreSQL data type | Specifies how data will be stored in the tag's PostgreSQL table column. Possible values are `text`, `int4`, or `real`. If the fourth column is `delete` or `phstore`, this column has no meaning and should just be set to `text`. |
| 4. Flags                | Zero or more flags separated by commas. For possible values see below. |
{: .desc}

Possible values for the flags are:

| Flag     | Description |
| -------- | --- |
| linear   | Specifies that ways with this tag should be imported as lines by default, even if they are closed. Other conditions can still override this. |
| polygon  | Specifies that closed ways with this tag should be imported as polygons by default. This will override any linear flags that would apply to the same object. Closed ways with `area=yes` and relations with `type=multipolygon` or `type=boundary` will be imported as polygons even if no polygon flag is set. Non-closed ways and closed ways with `area=no` will always be imported as lines. |
| nocolumn | The two flags above automatically create a column for the specified tag. This flag overrides this behaviour such that no column is created. This is especially useful for hstore, where all key value data is stored in the hstore column such that no dedicated columns are needed. |
| phstore  | The same as `polygon,nocolumn` for backward compatibility |
| delete   | Prevents the specified tag (but not the entire object) from being stored in the database. Useful for tags that tend to have long values but will not be used for rendering, such as `source=*`. This flag only affects `--slim` mode imports. |
| phstore  | Behaves like the polygon flag, but is used in hstore mode when you do not want to turn the tag into a separate PostgreSQL column. |
| nocache  | This flag is deprecated and does nothing. |
{: .desc}

The style file may also contain comments. Any text between a `#` and the end of
the line will be ignored.

#### Special 'tags'

There are several special values that can be used in the tag column (second
column) of the style file for creating additional fields in the database which
contain things other than tag values.

| Special tag   | Description |
| ------------- | --- |
| way_area      | Creates a database column that stores the area (calculated in the units of the projection, normally Mercator meters) for any objects imported as polygons. Use with `real` as the data type. See also the `--reproject-area` option. |
| z_order       | Adds a column that is used for ordering objects in the render. It mostly applies to objects with `highway=*` or `railway=*`. Use with `int4` as the data type. |
| osm_user      | Adds a column that stores the username of the last user to edit an object in the database (\*). |
| osm_uid       | Adds a column that stores the user ID number of the last user to edit an object in the database (\*). |
| osm_version   | Adds a column that stores the version of an object in the database (ie, how many times the object has been modified) (\*). |
| osm_timestamp | Adds a column that stores the date and time that the most recent version of an object was added to OpenStreetMap (\*). |
{: .desc}

To use these, you must use the command line option `--extra-attributes` when
importing.
{: .table-note}

### Schemas and Tablespaces

Usually all tables, indexes and functions that the pgsql output creates are
in the default public schema and use the default tablespace.

*Version >= 1.4.0*{: .version} You can use the command line option
`--output-pgsql-schema=SCHEMA` to tell osm2pgsql that it should use the
specified schema to create the tables, indexes, and functions in. Note that you
have to create the schema before running osm2pgsql and make sure the database
user was granted the rights to create tables, indexes, and functions in this
schema. Read more about schemas in the [PostgreSQL
documentation](https://www.postgresql.org/docs/current/ddl-schemas.html){:.extlink}.

Sometimes you want to create special [PostgreSQL
tablespaces](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html){:.extlink}
and put some tables or indexes into them. Having often used indexes on fast SSD
drives, for instance, can speed up processing a lot. There are three command
line options that the pgsql output interprets: To set the tablespace for output
tables and indexes, use the `--tablespace-main-data=TABLESPC` and
`--tablespace-main-index=TABLESPC` options, respectively. You can also use the
`-i, --tablespace-index=TABLESPC` option which will set the tablespace for the
pgsql output as well as for the middle! Note that it is your job to create the
tablespaces before calling osm2pgsql and making sure the disk behind it is
large enough.

### Coastline Processing

The `natural=coastline` tag is suppressed by default, even if you import the
`natural=*` key. Many maps get the coastlines [from a different
source](https://osmdata.openstreetmap.de/){:.extlink}, so it does not need to
import them from the input file. You can use the `--keep-coastlines` parameter
to change this behavior if you want coastlines in your database. See [the OSM
wiki](https://wiki.openstreetmap.org/wiki/Coastline){:.extlink} for more
information on coastline processing.

### Pgsql Output command line options

These are the command line options interpreted by the pgsql output:

{% include_relative options/pgsql.md %}

