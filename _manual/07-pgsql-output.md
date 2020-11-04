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
default is `planet_osm`. (Note that this option is also interpreted by the
middle!)

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

### Style File

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

#### Special 'Tags'

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

### Use of Hstore

Hstore is a [PostgreSQL data
type](http://www.postgresql.org/docs/current/static/hstore.html){:.extlink}
that allows storing arbitrary key-value pairs in a single column. It needs to
be installed on the database with `CREATE EXTENSION hstore;`

Hstore is used to give more flexibility in using additional tags without
reimporting the database, at the cost of a
[less speed and more space.](http://www.paulnorman.ca/blog/2014/03/osm2pgsql-and-hstore/){:.extlink}

By default, the pgsql output will not generate hstore columns. The following
options are used to add hstore columns of one type or another:

* `--hstore` or `-k` adds any tags not already in a conventional column to
  a hstore column called `tags`. With the default stylesheet this would result
  in tags like `highway` appearing in a conventional column while tags not in
  the style like `name:en` or `lanes:forward` would appear only in the hstore
  column.

* `--hstore-all` or `-j` adds all tags to a hstore column called `tags`, even if they're
  already stored in a conventional column. With the standard stylesheet this
  would result in tags like `highway` appearing in conventional column and the
  hstore column while tags not in the style like `name:en` or
  `lanes:forward` would appear only in the hstore column.

* `--hstore-column` or `-z`, which adds an additional column for tags
  starting with a specified string, e.g. `--hstore-column 'name:'` produces
  a hstore column that contains all `name:xx` tags. This option can be used
  multiple times.

You can not use both `--hstore` and `--hstore-all` together.

The following options can be used to modify the behaviour of the hstore
columns:

* `--hstore-match-only` modifies the above options and prevents objects from
  being added if they only have tags in the hstore column and no tags in the
  non-hstore columns. If neither of the above options is specified, this
  option is ignored.

* `--hstore-add-index` adds indexes to all hstore columns. This option is
  ignored if there are no hstore columns. Using indexes can speed up
  arbitrary queries, but for most purposes partial indexes will be
  faster. You have to create those yourself.

Either `--hstore` or `--hstore-all` when combined with `--hstore-match-only`
should give the same rows as no hstore, just with the additional hstore column.

Note that when you are using the `--extra-attributes` option, all your nodes,
ways, and relations essentially get a few extra tags. Together with the hstore
options above, the object attributes might end up in your hstore column(s)
possibly using quite a lot of space. This is especially true for the majority
of nodes that have no tags at all, so they would normally not appear in your
output tables. You might want to use `--hstore-match-only` in that case.

### Lua Tag Transformations

The pgsql output supports [Lua](https://lua.org/) scripts to rewrite tags
before they enter the database.

Note that this is a totally different mechanism than the [Lua scripts used in
the flex output](#the-style-file).
{:.note}

This allows you to unify disparate tagging (for example, `highway=path;
foot=yes` and `highway=footway`) and perform complex queries, potentially more
efficiently than writing them as rules in your Mapnik or other stylesheet.

#### How To

Pass a Lua script to osm2pgsql using the command line switch `--tag-transform-script`:

```sh
osm2pgsql -d gis -S your.style --tag-transform-script your.lua --hstore-all extract.osm.pbf
```

This Lua script needs to implement the following functions:

```lua
function filter_tags_node(tags, num_tags)
return filter, tags

function filter_tags_way(tags, num_tags)
return filter, tags, polygon, roads

function filter_basic_tags_rel(tags, num_tags)
return filter, tags
```

These take a set of tags as a Lua key-value table, and an integer which is the
number of tags supplied.

The first return value is `filter`, a flag which you should set to `1` if the
way/node/relation should be filtered out and not added to the database, `0`
otherwise. (They will still end up in the slim mode tables, but not in the
rendering tables.)

The second return value is `tags`, a transformed (or unchanged) set of tags.

`filter_tags_way` returns two additional flags. `poly` should be `1` if the way
should be treated as a polygon, `0` as a line. `roads` should be `1` if the way
should be added to the `planet_osm_roads` table, `0` otherwise.

    function filter_tags_relation_member(tags, member_tags,
        roles, num_members)
    return filter, tags, member_superseded, boundary,
        polygon, roads

The function `filter_tags_relation_member` is more complex and can handle more
advanced relation tagging, such as multipolygons that take their tags from the
member ways.

This function is called with the tags from the relation; a set of tags for each
of the member ways (member relations and nodes are ignored); the set of roles
for each of the member ways; and the number of members. The tag and role sets
are both arrays (indexed tables) of hashes (tables).

As usual, it should return a filter flag, and a transformed set of tags to be
applied to the relation in later processing.

The third return value, `member_superseded`, is obsolete and will be ignored.

The fourth and fifth return values, `boundary` and `polygon`, are flags that
specify if the relation should be processed as a line, a polygon, or both (e.g.
administrative boundaries).

The final return value, `roads`, is `1` if the geometry should be added to the
`planet_osm_roads` table.

There is a sample tag transform lua script in the repository as an example,
which (nearly) replicates current processing and can be used as a template for
one's own scripts.

#### In Practice

There is inevitably a performance hit with any extra processing. The sample Lua
tag transformation is a little slower than the C++-based default. However,
extensive Lua pre-processing may save you further processing in your Mapnik (or
other) stylesheet.

Test your Lua script with small excerpts before applying it to a whole country
or even the planet.

Where possible, add new tags, don't replace existing ones; otherwise you will
be faced with a reimport if you decide to change your transformation.

### Pgsql Output Command Line Options

These are the command line options interpreted by the pgsql output:

{% include_relative options/pgsql.md %}

