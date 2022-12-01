---
chapter: 6
title: The Flex Output
---

*Version 1.3.0 to 1.4.2*{: .version} The *flex* output appeared first in version
1.3.0 of osm2pgsql. It was marked as experimental until version 1.4.2

The *flex* output, as the name suggests, allows for a flexible configuration
that tells osm2pgsql what OSM data to store in your database and exactly where
and how. It is configured through a Lua file which

* defines the structure of the output tables and
* defines functions to map the OSM data to the database data format

Use the `-S, --style=FILE` option to specify the name of the Lua file along
with the `-O flex` or `--output=flex` option to specify the use of the flex
output.

Unlike the pgsql output, the flex output doesn't use command line options
for configuration, but the Lua config file only.
{: .note}

The flex style file is a Lua script. You can use all the power of the [Lua
language](https://www.lua.org/){:.extlink}. It gives you a lot of freedom to
write complex preprocessing scripts that might even use external libraries
to extend the capabilities of osm2pgsql. But it also means that the scripts
may mess with any part of your system when written badly. Only run Lua
scripts from trusted sources!

This description assumes that you
are somewhat familiar with the Lua language, but it is pretty easy to pick up
the basics and you can use the example config files in the
[`flex-config`](https://github.com/openstreetmap/osm2pgsql/tree/master/flex-config){:.extlink}
directory which contain lots of comments to get you started.

All configuration is done through the `osm2pgsql` global object in Lua. It has
the following fields and functions:

| Field / Function                                | Description |
| ----------------------------------------------- | ----------- |
| version                                         | The version of osm2pgsql as a string. |
| config_dir                                      | *Version >=1.5.1*{: .version} The directory where your Lua config file is. Useful when you want to include more files from Lua. |
| mode                                            | Either `"create"` or `"append"` depending on the command line options (`-c, --create` or `-a, --append`). |
| stage                                           | Either `1` or `2` (1st/2nd stage processing of the data). See below. |
| define_node_table(NAME, COLUMNS[, OPTIONS])     | Define a node table. |
| define_way_table(NAME, COLUMNS[, OPTIONS])      | Define a way table. |
| define_relation_table(NAME, COLUMNS[, OPTIONS]) | Define a relation table. |
| define_area_table(NAME, COLUMNS[, OPTIONS])     | Define an area table. |
| define_table(OPTIONS)                           | Define a table. This is the more flexible function behind all the other `define_*_table()` functions. It gives you more control than the more convenient other functions. |
{: .desc}

Osm2pgsql also provides some additional functions in the
Lua helper library described in [Appendix B](#lua-library-for-flex-output).

### Defining a Table

You have to define one or more database tables where your data should end up.
This is done with the `osm2pgsql.define_table()` function or, more commonly,
with one of the slightly more convenient functions
`osm2pgsql.define_(node|way|relation|area)_table()`.
In create mode, osm2pgsql will create those tables for you in the database.

#### Basic Table Definition

The simple way to define a table looks like this:

```
osm2pgsql.define_(node|way|relation|area)_table(NAME, COLUMNS[, OPTIONS])
```

Here `NAME` is the name of the table, `COLUMNS` is a list of Lua tables
describing the columns as documented below. `OPTIONS` is a Lua table with
options for the table as a whole. An example might be more helpful:

```lua
local restaurants = osm2pgsql.define_node_table('restaurants', {
    { column = 'name', type = 'text' },
    { column = 'tags', type = 'jsonb' },
    { column = 'geom', type = 'point' }
})
```

In this case we are creating a table that is intended to be filled with OSM
nodes, the table called `restaurants` will be created in the database with four
columns: A `name` column of type `text` (which will presumably later be filled
with the name of the restaurant), a column called `tags` with type `jsonb`
(which will presumable be filled later with all tags of a node), a column
called `geom` which will contain the Point geometry of the node and an Id
column called `node_id`.

Each table is either a *node table*, *way table*, *relation table*, or *area
table*. This means that the data for that table comes primarily from a node,
way, relation, or area, respectively. Osm2pgsql makes sure that the OSM object
id will be stored in the table so that later updates to those OSM objects (or
deletions) will be properly reflected in the tables. Area tables are special,
they can contain data derived from ways and from (multipolygon) relations.

#### Advanced Table Definition

Sometimes the `define_(node|way|relation|area)_table()` functions are a bit too
restrictive, for instance if you want more control over the type and naming of
the Id column(s). In this case you can use the function
`osm2pgsql.define_table()`.

Here are the available `OPTIONS` for the `osm2pgsql.define_table(OPTIONS)`
function. You can use the same options on the
`define_(node|way|relation|area)_table()` functions, except the `name` and
`columns` options.

| Table Option     | Description |
| ---------------- | ----------- |
| name             | The name of the table (without schema). |
| ids              | A Lua table defining how this table should handle ids (see the [Id Handling](#id-handling) section for details). Note that you can define tables without Ids, but they can not be updated by osm2pgsql. |
| columns          | An array of columns (see the [Defining Columns](#defining-columns) section for details). |
| schema           | Set the [PostgreSQL schema](https://www.postgresql.org/docs/current/ddl-schemas.html){:. extlink} to be used for this table. The schema must exist in the database before you start osm2pgsql. By default no schema is set which usually means the tables will be created in the `public` schema. |
| data_tablespace  | The [PostgreSQL tablespace](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html){:.extlink} used for the data in this table. |
| index_tablespace | The [PostgreSQL tablespace](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html){:.extlink} used for all indexes of this table. |
| cluster          | *Version >= 1.5.0*{: .version} Set clustering strategy. Use `"auto"` (default) to enable clustering by geometry, osm2pgsql will choose the best method. Use `"no"` to disable clustering. |
| indexes          | *Version >= 1.8.0*{: .version} Define indexes to be created on this table. If not set, the default is to create a GIST index on the first (or only) geometry column. |
{: .desc}

All the `osm2pgsql.define*table()` functions return a database table Lua
object. You can call the following functions on it:

| Function  | Description |
| --------- | ----------- |
| name()    | The name of the table as specified in the define function. |
| schema()  | The schema of the table as specified in the define function. |
| columns() | The columns of the table as specified in the define function. |
| add_row() | Add a row to the database table. See below for details. |
| insert()  | *Version >= 1.7.0*{: .version} Add a row to the database table. See below for details. |
{: .desc}

### Id Handling

Id columns allows osm2pgsql to track which database table entries have been
generated by which objects. When objects change or are deleted, osm2pgsql uses
the ids to update or remove all existing rows from the database with those ids.

If you are using the `osm2pgsql.define_(node|way|relation|area)_table()`
convenience functions, osm2pgsql will automatically create an id column named
`(node|way|relation|area)_id`, respectively.

If you want more control over the id column(s), use the
`osm2pgsql.define_table()` function. You can then use the `ids` option to
define how the id column(s) should look like. To generate the same
"restaurants" table described above, the `define_table()` call will look like
this:

```lua
local restaurants = osm2pgsql.define_table({
    name = 'restaurants',
    ids = { type = 'node', id_column = 'node_id' },
    columns = {
        { column = 'name', type = 'text' },
        { column = 'tags', type = 'jsonb' },
        { column = 'geom', type = 'point' }
}})
```

If you don't have an `ids` field, the table is generated without Id. Tables
without Id can not be updated, so you can fill them in create mode, but they
will not work in append mode.

The following values are allowed for the `type` of the `ids` field:

| Type     | Description |
| -------- | ----------- |
| node     | A node Id will be stored 'as is' in the column named by `id_column`. |
| way      | A way Id will be stored 'as is' in the column named by `id_column`. |
| relation | A relation Id will be stored 'as is' in the column named by `id_column`. |
| area     | A way Id will be stored 'as is' in the column named by `id_column`, for relations the Id will be stored as negative number. |
| any      | Any type of object can be stored. See below. |
{: .desc}

The `any` type is for tables that can store any type of OSM object (nodes,
ways, or relations). There are two ways the id can be stored:

1. If you have a `type_column` setting in your `ids` field, it will store the
   type of the object in an additional `char(1)` column as `N`, `W`, or `R`.
2. If you don't have a `type_column`, the id of nodes stays the same (so they
   are positive), way ids will be stored as negative numbers and relation ids
   are stored as negative numbers and 1e17 is subtracted from them. This
   results in distinct ranges for all ids so they can be kept apart.
   (This is the same transformation that the
   [Imposm](https://imposm.org/docs/imposm3/latest/){:.extlink} program uses.)

#### Unique Ids

It is often desirable to have a unique PRIMARY KEY on database tables. Many
programs need this.

There seems to be a natural unique key, the OSM node, way, or relation ID the
data came from. But there is a problem with that: Depending on the
configuration, osm2pgsql sometimes adds several rows to the output tables with
the same OSM ID. This typically happens when long linestrings are split into
shorter pieces or multipolygons are split into their constituent polygons, but
it can also happen if your Lua configuration adds two rows to the same table.

If you need unique keys on your database tables there are two options: Using
those natural keys and making sure that you don't have duplicate entries. Or
adding an additional ID column. The latter is easier to do and will work in
all cases, but it adds some overhead.

#### Using Natural Keys for Unique Ids

To use OSM IDs as primary keys, you have to make sure that

* you only ever add a single row per OSM object to an output table, i.e. do
  not call `add_row` multiple times on the same table for the same OSM object.
* osm2pgsql doesn't split long linestrings into smaller ones or multipolygons
  into polygons. So you can not use the `split_at` option on the geometry
  transformation.
* *Version == 1.3.0*{: .version} osm2pgsql doesn't split multipolygons into
  polygons. So you have to set `multi = true` on all `area` geometry
  transformations.

You probably also want an index on the ID column. If you are running in slim
mode, osm2pgsql will create that index for you. But in non-slim mode you have
to do this yourself with `CREATE UNIQUE INDEX`. You can also use [`ALTER
TABLE`](https://www.postgresql.org/docs/current/sql-altertable.html){:.extlink}
to make the column an "official" primary key column.

#### Using an Additional ID Column

PostgreSQL has the somewhat magic
["serial" data type](https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL){:.extlink}.
If you use that datatype in a column definition, PostgreSQL will add an
integer column to the table and automatically fill it with an autoincrementing
value.

In the flex config you can add such a column to your tables with something
like this:

```lua
...
{ column = 'id', sql_type = 'serial', create_only = true },
...
```

The `create_only` tells osm2pgsql that it should create this column but not
try to fill it when adding rows (because PostgreSQL does it for us).

You probably also want an index on this column. After the first import of your
data using osm2pgsql, use `CREATE UNIQUE INDEX` to create one. You can also use
[`ALTER
TABLE`](https://www.postgresql.org/docs/current/sql-altertable.html){:.extlink}
to make the column an "official" primary key column.

Since PostgreSQL 10 you can use the `GENERATED ... AS IDENTITY` clause instead
of the `SERIAL` type which does something very similar, although using anything
but a proper PostgreSQL type here is not officially supported.

### Defining Columns

In the table definitions the columns are specified as a list of Lua tables
with the following keys:

| Key         | Description |
| ----------- | ----------- |
| column      | The name of the PostgreSQL column (required). |
| type        | The type of the column (Optional, default `'text'`). |
| sql_type    | *Version >= 1.5.0*{: .version} The SQL type of the column (Optional, default depends on `type`, see next table). In versions before 1.5.0 the `type` field was used for this also. |
| not_null    | Set to `true` to make this a `NOT NULL` column. (Optional, default `false`.) |
| create_only | Set to `true` to add the column to the `CREATE TABLE` command, but do not try to fill this column when adding data. This can be useful for `SERIAL` columns or when you want to fill in the column later yourself. (Optional, default `false`.) |
| projection  | On geometry columns only. Set to the EPSG id or name of the projection. (Optional, default web mercator, `3857`.) |
{: .desc}

The `type` field describes the type of the column from the point of view of
osm2pgsql, the `sql_type` describes the type of the column from the point of
view of the PostgreSQL database. Usually they are either the same or the
SQL type is derived directly from the `type` according to the following table.
But it is possible to set them individually for special cases.

*Version < 1.5.0*{: .version} The `sql_type` field did not exist in earlier
versions. Use the `type` field instead. If you are upgrading from a version <
1.5.0 to 1.5.0 or above, it is usually enough to set the `sql_type` to the same
value that the `type` field had before for every `type` field where you get an
error message from osm2pgsql.
{: .note}

| `type`             | Default for `sql_type` | Notes       |
| ------------------ | ---------------------- | ----------- |
| text               | `text`                 | *(default)* |
| bool, boolean      | `boolean`              | |
| int2, smallint     | `int2`                 | |
| int4, int, integer | `int4`                 | |
| int8, bigint       | `int8`                 | |
| real               | `real`                 | |
| hstore             | `hstore`               | PostgreSQL extension `hstore` must be loaded |
| json               | `json`                 | |
| jsonb              | `jsonb`                | |
| direction          | `int2`                 | |
| geometry           | `geometry(GEOMETRY, *SRID*)`           | (\*) |
| point              | `geometry(POINT, *SRID*)`              | (\*) |
| linestring         | `geometry(LINESTRING, *SRID*)`         | (\*) |
| polygon            | `geometry(POLYGON, *SRID*)`            | (\*) |
| multipoint         | `geometry(MULTIPOINT, *SRID*)`         | (\*) |
| multilinestring    | `geometry(MULTILINESTRING, *SRID*)`    | (\*) |
| multipolygon       | `geometry(MULTIPOLYGON, *SRID*)`       | (\*) |
| geometrycollection | `geometry(GEOMETRYCOLLECTION, *SRID*)` | (\*) *Only available in version >= 1.7.0*{: .version} |
| area               | `real `                | |
{: .desc}

The `SRID` for the geometry SQL types comes from the `projection` parameter.
{: .table-note}

For special cases you usually want to keep the `type` field unset and only
set the `sql_type` field. So if you want to have an array of integer column,
for instance, set only the `sql_type` to `int[]`. The `type` field will default
to `text` which means you have to create the text representation of your array
in the form that PostgreSQL expects it.

For details on how the data is converted depending on the type, see the section
on [Type Conversions](#type-conversions).

The content of the `sql_type` field is not checked by osm2pgsql, it is passed
on to PostgreSQL as is. Do not set this to anything else but a valid PostgreSQL
type.
{: .note}


#### Defining Geometry Columns

Most tables will have a geometry column. The types of the geometry column
possible depend on the type of the input data. For node tables you are pretty
much restricted to point geometries, but there is a variety of options for
relation tables for instance.

*Version < 1.7.0*{: .version} Only zero or one geometry columns are supported.

*Version >= 1.7.0*{: .version} You can have any number of geometry columns if
you are using the `insert()` command on a table (and not `add_row()`, see
below).

An index will only be built automatically for the first (or only) geometry
column you define. The table will be [clustered](#clustering-by-geometry) by
the first (or only) geometry column (unless disabled).

The supported geometry types are:

| Geometry type      | Description |
| ------------------ | ----------- |
| point              | Point geometry, usually created from nodes. |
| linestring         | Linestring geometry, usually created from ways. |
| polygon            | Polygon geometry for area tables, created from ways or relations. |
| multipoint         | Currently not used. |
| multilinestring    | Created from (possibly split up) ways or relations. |
| multipolygon       | For area tables, created from ways or relations. |
| geometrycollection | Geometry collection, created from relations. *Only available in version >= 1.7.0*{: .version} |
| geometry           | Any kind of geometry. Also used for area tables that should hold both polygon and multipolygon geometries. |
{: .desc}

By default geometry columns will be created in web mercator (EPSG 3857). To
change this, set the `projection` parameter of the column to the EPSG code
you want (or one of the strings `latlon(g)`, `WGS84`, or `merc(ator)`, case
is ignored).

There is one special geometry column type called `area`. It can be used in
addition to a `polygon` or `multipolygon` column. Unlike the normal geometry
column types, the resulting database type will not be a geometry type, but
`real`. It will be filled automatically with the area of the geometry. The area
will be calculated in web mercator, or you can set the `projection` parameter
of the column to `4326` to calculate it with WGS84 coordinates. Other
projections are currently not supported.

*Version >= 1.7.0*{:.version} If you are using the `insert()` command on a
table (and not `add_row()`, see below) you can use the `area()` function on any
geometry in any projection to calculate the area. What you get back is a real
number that you can put into any normal `real` column. The special case of the
`area` column type is not needed any more.

### Defining Indexes

Osm2pgsql will always create indexes on the id column(s) of all tables if the
database is updateable (i.e. in slim mode), because it needs those indexes to
update the database. You can not control those indexes with the settings
described in this section.
{: .note}

*Version >= 1.8.0*{:.version} Indexes can only be defined in version 1.8.0 and
above, before that there was always a GIST index created on the first (or only)
geometry column of any table.

To define indexes, set the `indexes` field of the table definition to an array
of Lua tables. If the array is empty, no indexes are created for this table
(except possibly an index on the id column(s)). If there is no `indexes` field
(or if it is set to `nil`) a GIST index will be created on the first (or only)
geometry column of this table. This is the same behavior as before version
1.8.0.

The following fields can be set in an index definition. You have to set at
least the `method` and either `column` or `expression`.

| Key        | Description |
| ---------- | ----------- |
| column     | The name of the column the index should be created on. Can also be an array of names. Required, unless `expression` is set. |
| expression | A valid SQL expression used for [indexes on expressions](https://www.postgresql.org/docs/current/indexes-expressional.html){:.extlink}. Can not be used together with `column`. |
| include    | A column name or list of column names to include in the index as non-key columns. (Only available from PostgreSQL 11.) |
| method     | The index method ('btree', 'gist', ...). See the [PostgreSQL docs](https://www.postgresql.org/docs/current/indexes-types.html){:.extlink} for available types (required). |
| tablespace | The tablespace where the index should be created. Default is the tablespace set with `index_tablespace` in the table definition. |
| unique     | Set this to `true` or `false` (default). |
| where      | A condition for a [partial index](https://www.postgresql.org/docs/current/indexes-partial.html){:.extlink}. This has to be set to a text that makes valid SQL if added after a `WHERE` in the `CREATE INDEX` command. |
{: .desc}

If you need an index that can not be expressed with these definitions, you have
to create it yourself using [the SQL `CREATE INDEX`
command](https://www.postgresql.org/docs/current/sql-createindex.html){:.extlink}
after osm2pgsql has finished its job.

### Processing Callbacks

You are expected to define one or more of the following functions:

| Callback function                  | Description                              |
| ---------------------------------- | ---------------------------------------- |
| osm2pgsql.process_node(object)     | Called for each new or changed node.     |
| osm2pgsql.process_way(object)      | Called for each new or changed way.      |
| osm2pgsql.process_relation(object) | Called for each new or changed relation. |
{: .desc}

They all have a single argument of type table (here called `object`) and no
return value. If you are not interested in all object types, you do not have
to supply all the functions.

These functions are called for each new or modified OSM object in the input
file. No function is called for deleted objects, osm2pgsql will automatically
delete all data in your database tables that were derived from deleted objects.
Modifications are handled as deletions followed by creation of a "new" object,
for which the functions are called.

You can do anything in those processing functions to decide what to do with
this data. If you are not interested in that OSM object, simply return from the
function. If you want to add the OSM object to some table call the `add_row()`
(*Version >= 1.7.0*{: .version} or `insert()`) function on that table.

The parameter table (`object`) has the following fields and functions:

| Field / Function | Description |
| ---------------- | ----------- |
| id               | The id of the node, way, or relation. |
| type             | *Version >= 1.7.0*{: .version} The object type as string (`node`, `way`, or `relation`). |
| tags             | A table with all the tags of the object. |
| version          | Version of the OSM object. (\*) |
| timestamp        | Timestamp of the OSM object, time in seconds since the epoch (midnight 1970-01-01). (\*) |
| changeset        | Changeset containing this version of the OSM object. (\*) |
| uid              | User id of the user that created or last changed this OSM object. (\*) |
| user             | User name of the user that created or last changed this OSM object. (\*) |
| grab_tag(KEY)    | Return the tag value of the specified key and remove the tag from the list of tags. (Example: `local name = object:grab_tag('name')`) This is often used when you want to store some tags in special columns and the rest of the tags in an jsonb or hstore column. |
| get_bbox()       | Get the bounding box of the current node, way, or relation. This function returns four result values: the lon/lat values for the bottom left corner of the bounding box, followed by the lon/lat values of the top right corner. Both lon/lat values are identical in case of nodes. Example: `lon, lat, dummy, dummy = object.get_bbox()` (*Version < 1.7.0*{: .version} Only for nodes and ways, *Version >= 1.7.0*{: .version} Also available for relations, relation members (nested relations) are not taken into account.) |
| is_closed        | Ways only: A boolean telling you whether the way geometry is closed, i.e. the first and last node are the same. |
| nodes            | Ways only: An array with the way node ids. |
| members          | Relations only: An array with member tables. Each member table has the fields `type` (values `n`, `w`, or `r`), `ref` (member id) and `role`. |
| as_point()              | Create point geometry from OSM node object. |
| as_linestring()         | Create linestring geometry from OSM way object. |
| as_polygon()            | Create polygon geometry from OSM way object. |
| as_multipoint()         | *Version >= 1.7.1*{: .version} Create (multi)point geometry from OSM node/relation object. |
| as_multilinestring()    | Create (multi)linestring geometry from OSM way/relation object. |
| as_multipolygon()       | Create (multi)polygon geometry from OSM way/relation object. |
| as_geometrycollection() | Create geometry collection from OSM relation object. |
{: .desc}

These are only available if the `-x|--extra-attributes` option is used and the
OSM input file actually contains those fields.
{: .table-note}

The `as_*` functions will return a NULL geometry (check with `is_null()`) if
the geometry can not be created for some reason, for instance a polygon can
only be created from closed ways. This can also happen if your input data is
incomplete, for instance when nodes referenced from a way are missing.

The `as_linestring()` and `as_polygon()` functions can only be used on ways.

*Version >= 1.7.1*{: .version} The `as_multipoint()` function can be used on
nodes and relations. For nodes it will always return a point geometry, for
relations a point or multipoint geometry with all available node members.

The `as_multilinestring()` and `as_multipolygon()` functions, on the other
hand, can be used for ways and for relations. The latter will either return
a linestring/polygon or a multilinestring/multipolygon, depending on whether
the result is a single geometry or a multi-geometry.

If you need all geometries of a relation, you can use
`as_geometrycollection()`. It will contain all geometries which can be
generated from node and way members of the relation in order of those members.
Members of type "relation" are ignored. Node members will result in a point
geometry, way members will result in a linestring geometry. Geometries that
can't be built are missing. (You can detect this by counting the number of
geometries with `num_geometries()` and comparing that to the number of
members of type node and relation.) If no valid geometry can be created, so
if the geometry collection would be empty, a null geometry is returned instead.

### The `add_row` function

```lua
-- definition of the table:
table_pois = osm2pgsql.define_node_table('pois', {
    { column = 'tags', type = 'jsonb' },
    { column = 'name', type = 'text' },
    { column = 'geom', type = 'point' },
})
...
function osm2pgsql.process_node(object)
...
    table_pois:add_row({
        tags = object.tags,
        name = object.tags.name,
        geom = { create = 'point' }
    })
...
end
```

The `add_row()` function takes a single table parameter, that describes what to
fill into all the database columns. Any column not mentioned will be set to
`NULL`.

The geometry column is somewhat special. You have to define a *geometry
transformation* that will be used to transform the OSM object data into
a geometry that fits into the geometry column. See the next section for
details. If you want more flexible geometry processing you need to use [the
`insert()` function](#the-insert-function) available in
*version >= 1.70*{:.version}.

Note that you can't set the object id, this will be handled for you behind the
scenes.

### Geometry Transformations for the `add_row()` Function

Currently these geometry transformations are supported:

* `{ create = 'point' }`. Only valid for nodes, create a 'point' geometry.
* `{ create = 'line' }`. For ways or relations. Create a 'linestring' or
  'multilinestring' geometry.
* `{ create = 'area' }` For ways or relations. Create a 'polygon' or
  'multipolygon' geometry.

Some of these transformations can have parameters:

* The `line` transformation has an optional parameter `split_at`. If this
  is set to anything other than 0, long linestrings will be split up into
  parts no longer than this value.
* *Version == 1.3.0*{: .version} The `area` transformation has an optional
  parameter `multi`. If this is set to `false` (the default), a multipolygon
  geometry will be split up into several polygons. If this is set to `true`,
  the multipolygon geometry is kept as one.
* *Version >= 1.4.0*{: .version} The `area` transformation has an optional
  parameter `split_at`. If this is not set or set to `nil` (the default),
  (multi)polygon geometries will be kept as is, if this is set to `'multi'`
  multipolygon geometries will be split into their polygon parts.

Note that in general it is your responsibility to make sure the column type
of a geometry column can take the geometries created by the transformation.
A `point` geometry column will not be able to store the result of an `area`
transformation.

*Version >= 1.4.0*{: .version} If a transformation will result in a polygon
geometry, but the column type of the geometry is `multipolygon`. The polygon
will be "wrapped" automatically in a multipolygon to fit into the column.
This can be useful when you want all your polygons and multipolygons to be
of the same database type. Some programs handle columns of uniform geometry
type better.

If no geometry transformation is set, osm2pgsql will, in some cases, assume
a default transformation. These are the defaults:

* For node tables, a `point` column gets the node location.
* For way tables, a `linestring` column gets the complete way geometry, a
  `polygon` column gets the way geometry as area (if the way is closed and
  the area is valid).

### The `insert()` Function

This function is only available in *Version >= 1.7.0*{: .version}. Use
`add_row()` in earlier versions.

```lua
-- definition of the table:
table_pois = osm2pgsql.define_node_table('pois', {
    { column = 'tags', type = 'jsonb' },
    { column = 'name', type = 'text' },
    { column = 'geom', type = 'point' },
})
...
function osm2pgsql.process_node(object)
...
    table_pois:insert({
        tags = object.tags,
        name = object.tags.name,
        geom = object:as_point()
    })
...
end
```

The `insert()` function takes a single table parameter, that describes what to
fill into all the database columns. Any column not mentioned will be set to
`NULL`. It returns `true` if the insert was successful.

Note that you can't set the object id, this will be handled for you behind the
scenes.

### Handling of NULL in `insert()` Function

Any column not set, or set to `nil` (which is the same thing in Lua), or set to
the null geometry, will be set to `NULL` in the database. If the column is
defined with `not_null = true` in the table definition, the row will not be
inserted. Usually that is just what you want, bad data is silently ignored that
way.

If you want to check whether the insert actually happened, you can look at the
return values of the `insert()` command. The `insert()` function actually
returns up to four values:

```lua
local inserted, message, column, object = table:insert(...)
```

| Value    | Description                                               |
|--------- | --------------------------------------------------------- |
| inserted | `true` if the row was inserted, `false` otherwise         |
| message  | A message telling you the reason why the insertion failed |
| column   | The name of the column that triggered the failure         |
| object   | The OSM object we are currently processing. Useful for, say, logging the id |
{:.desc}

The last three are only set if the first is `false`.

### Stages

When processing OSM data, osm2pgsql reads the input file(s) in order, nodes
first, then ways, then relations. This means that when the ways are read and
processed, osm2pgsql can't know yet whether a way is in a relation (or in
several). But for some use cases we need to know in which relations a way is
and what the tags of these relations are or the roles of those member ways.
The typical case are relations of type `route` (bus routes etc.) where we
might want to render the `name` or `ref` from the route relation onto the
way geometry.

The osm2pgsql flex output supports this use case by adding an additional
"reprocessing" step. Osm2pgsql will call the Lua function
`osm2pgsql.select_relation_members()` for each added, modified, or deleted
relation. Your job is to figure out which way members in that relation might
need the information from the relation to be rendered correctly and return
those ids in a Lua table with the only field 'ways'. This is usually done with
a function like this:

```lua
function osm2pgsql.select_relation_members(relation)
    if relation.tags.type == 'route' then
        return { ways = osm2pgsql.way_member_ids(relation) }
    end
end
```

Instead of using the helper function `osm2pgsql.way_member_ids()` which
returns the ids of all way members, you can write your own code, for instance
if you want to check the roles.

Note that `select_relation_members()` is called for deleted relations and for
the old version of a modified relation as well as for new relations and the
new version of a modified relation. This is needed, for instance, to correctly
mark member ways of deleted relations, because they need to be updated, too.
The decision whether a way is to be marked or not can only be based on the
tags of the relation and/or the roles of the members. If you take other
information into account, updates might not work correctly.

In addition you have to store whatever information you need about the relation
in your `process_relation()` function in a global variable.

After all relations are processed, osm2pgsql will reprocess all marked ways by
calling the `process_way()` function for them again. This time around you have
the information from the relation in the global variable and can use it.

If you don't mark any ways, nothing will be done in this reprocessing stage.

(It is currently not possible to mark nodes or relations. This might or might
not be added in future versions of osm2pgsql.)

You can look at `osm2pgsql.stage` to see in which stage you are.

You want to do all the processing you can in stage 1, because it is faster
and there is less memory overhead. For most use cases, stage 1 is enough.

Processing in two stages can add quite a bit of overhead. Because this feature
is new, there isn't much operational experience with it. So be a bit careful
when you are experimenting and watch memory and disk space consumption and
any extra time you are using. Keep in mind that:

* All data stored in stage 1 for use in stage 2 in your Lua script will use
  main memory.
* Keeping track of way ids marked in stage 1 needs some memory.
* To do the extra processing in stage 2, time is needed to get objects out
  of the object store and reprocess them.
* Osm2pgsql will create an id index on all way tables to look up ways that
  need to be deleted and re-created in stage 2.

### Type Conversions

The `add_row()` and `insert()` functions will try its best to convert Lua
values into corresponding PostgreSQL values. But not all conversions make
sense. Here are the detailed rules:

1. Lua values of type `function`, `userdata`, or `thread` will always result in
   an error.
2. The Lua type `nil` is always converted to `NULL`.
3. If the result of a conversion is `NULL` and the column is defined as `NOT
   NULL`, an error is thrown from the `add_row()` function. See
   [above](#handling-of-null-in-insert-function) for `NULL` handling in
   `insert()`.
4. The Lua type `table` is converted to the PostgreSQL type `hstore` if and
   only if all keys and values in the table are string values.
5. For `boolean` columns: The number `0` is converted to `false`, all other
   numbers are `true`. Strings are converted as follows: `"yes"`, `"true"`,
   `"1"` are `true`; `"no"`, `"false"`, `"0"` are `false`, all others are
   `NULL`.
6. For integer columns (`int2`, `int4`, `int8`): Boolean `true` is converted
   to `1`, `false` to `0`. Numbers that are not integers or outside the range
   of the type result in `NULL`. Strings are converted to integers if possible
   otherwise the result is `NULL`.
7. For `real` columns: Booleans result in an error, all numbers are used as
   is, strings are converted to a number, if that is not possible the result
   is `NULL`.
8. For `direction` columns (stored as `int2` in the database): Boolean `true`
   is converted to `1`, `false` to `0`. The number `0` results in `0`, all
   positive numbers in `1`, all negative numbers in `-1`. Strings `"yes"` and
   `"1"` will result in `1`, `"no"` and `"0"` in `0`, `"-1"` in `-1`. All
   other strings will result in `NULL`.
9. *Version >= 1.5.0*{: .version} For `json` and `jsonb` columns string,
   number, and boolean values are converted to their JSON equivalent as you
   would expect. (The special floating point numbers `NaN` and `Inf` can not be
   represented in JSON and are converted to `null`). An empty table is converted
   to an (empty) JSON object, tables that only have consecutive integer keys
   starting from 1 are converted into JSON arrays. All other tables are converted
   into JSON objects. Mixed key types are not allowed. Osm2pgsql will detect loops
   in tables and return an error.
10. For text columns and any other not specially recognized column types,
    booleans result in an error and numbers are converted to strings.
11. *Version >= 1.7.0*{: .version} For `insert()` only: Geometry objects are
    converted to their PostGIS counterparts. Null geometries are converted to
    database `NULL`. Geometries in WGS84 will automatically be transformed into
    the target column SRS if needed. Non-multi geometries will automatically be
    transformed into multi-geometries if the target column has a multi-geometry
    type.

If you want any other conversions, you have to do them yourself in your Lua
code. Osm2pgsql provides some helper functions for other conversions, see
the Lua helper library ([Appendix B](#lua-library-for-flex-output)).

Conversion to `json` and `jsonb` columns is only available from osm2pgsql
1.5.0 onwards. In versions before that you have to provide valid JSON from
your Lua script to those columns yourself.
{: .note}

### Geometry Objects in Lua

*Version >= 1.7.0*{:.version}

Lua geometry objects are created by calls such as `object:as_point()` or
`object:as_polygon()` inside processing functions. It is not possible to
create geometry objects from scratch, you always need an OSM object.

You can write geometry objects directly into geometry columns in the database
using the table `insert()` function. (You can not do that using the `add_row()`
function, it has a different geometry handling, see above.) But you can also
transform geometries in multiple ways.

Geometry objects have the following functions. They are modelled after the
PostGIS functions with equivalent names.

| Function                         | Description |
| -------------------------------- | ----------- |
| `area()`                         | Returns the area of the geometry. For any geometry type but (MULTI)POLYGON this is always `0.0`. The area is calculated using the SRS of the geometry, the result is in map units. |
| `length()`                       | *Version >= 1.7.1*{:.version} Returns the length of the geometry. For any geometry type but (MULTI)LINESTRING this is always `0.0`. The length is calculated using the SRS of the geometry, the result is in map units. |
| `centroid()`                     | Return the centroid (center of mass) of a geometry. (Implemented for all geometry types in *Version >= 1.7.1*{:.version}.) |
| `geometries()`                   | Returns an iterator for iterating over member geometries of a multi-geometry. See below for detail. |
| `geometry_n()`                   | Returns the nth geometry (1-based) of a multi-geometry. |
| `geometry_type()`                | Returns the type of geometry as a string: `NULL`, `POINT`, `LINESTRING`, `POLYGON`, `MULTIPOINT`, `MULTILINESTRING`, `MULTIPOLYGON`, or `GEOMETRYCOLLECTION`.
| `is_null()`                      | Returns `true` if the geometry is a NULL geometry, `false` otherwise. |
| `line_merge()`                   | Merge lines in a (MULTI)LINESTRING as much as possible into longer lines. |
| `num_geometries()`               | Returns the number of geometries in a multi-geometry. Always 0 for NULL geometries and always 1 for non-multi geometries. |
| `segmentize(max_segment_length)` | Segmentize a (MULTI)LINESTRING, so that no segment is longer than `max_segment_length`. Result is a (MULTI)LINESTRING. |
| `simplify(tolerance)`            | Simplify (MULTI)LINESTRING geometries with the Douglas-Peucker algorithm. (Currently not implemented for other geometry types. For multilinestrings only available in *Version >= 1.7.1*{: .version}) |
| `srid()`                         | Return SRID of the geometry. |
| `transform(target_srid)`         | Transform the geometry to the target SRS. |
{:.desc}

The Lua length operator (`#`) returns the number of geometries in the geometry
object, it is synonymous to calling `num_geometries()`.

Converting a geometry to a string (`tostring(geom)`) returns the geometry type
(as with the `geometry_type()` function).

All geometry functions that return geometries will return a NULL geometry on
error. All geometry functions handle NULL geometry on input in some way. So you
can always chain geometry functions and if there is any problem on the way, the
result will be a NULL geometry. Here is an example:

```lua
local area = object:as_polygon():transform(3857):area()
-- area will be 0.0 if not a polygon or transformation failed
```

To iterate over the members of a multi-geometry use the `geometries()` function:

```lua
local geom = object:as_multipolygon()
for g in geom:geometries() do
    landuse.insert({
        geom = g,
        ...
    })
end
```

In Lua you can not get at the actual contents of the geometries, i.e. the
coordinates and such. This is intentional. Writing functions in Lua that do
something with the coordinates will be much slower than writing those functions
in C++, so Lua scripts should concern themselves only with the high-level
control flow, not the details of the geometry. If you think you need some
function to access the internals of a geometry, [start a discussion on
Github](https://github.com/openstreetmap/osm2pgsql/discussions).

