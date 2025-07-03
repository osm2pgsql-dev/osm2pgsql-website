---
chapter: 6
title: The Flex Output
---

The *flex* output, as the name suggests, allows for a flexible configuration
that tells osm2pgsql what OSM data to store in your database and exactly where
and how. It is configured through a Lua file which

* defines the structure of the output tables and
* defines functions to map the OSM data to the database data format

Use the `-S, --style=FILE` option to specify the name of the Lua file along
with the `-O flex` or `--output=flex` option to specify the use of the flex
output.

The *flex* output is much more capable than the legacy *pgsql*, which will
be removed at some point. Use the *flex* output for any new projects and
switch old projects over.
{:.tip}

The flex style file is a Lua script. You can use all the power of the [Lua
language](https://www.lua.org/){:.extlink}. It gives you a lot of freedom to
write complex preprocessing scripts that might even use external libraries
to extend the capabilities of osm2pgsql. But it also means that the scripts
may mess with any part of your system when written badly. Only run Lua
scripts from trusted sources!

This description assumes that you
are somewhat familiar with the Lua language, but it is pretty easy to pick up
the basics and you can use the example config files in the
[`flex-config`](https://github.com/osm2pgsql-dev/osm2pgsql/tree/master/flex-config){:.extlink}
directory which contain lots of comments to get you started.

All configuration is done through the `osm2pgsql` global object in Lua. It has
the following fields and functions:

| Field / Function                                              | Description |
| ------------------------------------------------------------- | ----------- |
| osm2pgsql.**version**                                         | The version of osm2pgsql as a string. |
| osm2pgsql.**config_dir**                                      | The directory where your Lua config file is. Useful when you want to include more files from Lua. |
| osm2pgsql.**mode**                                            | Either `"create"` or `"append"` depending on the command line options (`-c, --create` or `-a, --append`). |
| osm2pgsql.**properties**                                      | A Lua table which gives read-only access to the contents of [the properties](#the-properties-table). |
| osm2pgsql.**stage**                                           | Either `1` or `2` (1st/2nd stage processing of the data). See below. |
| osm2pgsql.**define_expire_output**(OPTIONS)                   | Define an expire output table or file. See below. |
| osm2pgsql.**define_node_table**(NAME, COLUMNS[, OPTIONS])     | Define a node table. |
| osm2pgsql.**define_way_table**(NAME, COLUMNS[, OPTIONS])      | Define a way table. |
| osm2pgsql.**define_relation_table**(NAME, COLUMNS[, OPTIONS]) | Define a relation table. |
| osm2pgsql.**define_area_table**(NAME, COLUMNS[, OPTIONS])     | Define an area table. |
| osm2pgsql.**define_table**(OPTIONS)                           | Define a table. This is the more flexible function behind all the other `define_*_table()` functions. It gives you more control than the more convenient other functions. |
{: .desc}

Osm2pgsql also provides some additional functions in the
Lua helper library described in [Appendix B](#lua-library-for-flex-output).

### Defining a Table

Usually you want to define one or more database tables where your data should
end up. This is done with the `osm2pgsql.define_table()` function or, more
commonly, with one of the slightly more convenient functions
`osm2pgsql.define_(node|way|relation|area)_table()`. In create mode, osm2pgsql
will create those tables for you in the database.

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

Sometimes the `osm2pgsql.define_(node|way|relation|area)_table()` functions are
a bit too restrictive, for instance if you want more control over the type and
naming of the Id column(s). In this case you can use the function
`osm2pgsql.define_table()`.

Here are the available `OPTIONS` for the `osm2pgsql.define_table(OPTIONS)`
function. You can use the same options on the
`osm2pgsql.define_(node|way|relation|area)_table()` functions, except the
`name` and `columns` options.

| Table Option     | Description |
| ---------------- | ----------- |
| name             | The name of the table (without schema). |
| ids              | A Lua table defining how this table should handle ids (see the [Id Handling](#id-handling) section for details). Note that you can define tables without Ids, but they can not be updated by osm2pgsql. |
| columns          | An array of columns (see the [Defining Columns](#defining-columns) section for details). |
| schema           | Set the [PostgreSQL schema](https://www.postgresql.org/docs/current/ddl-schemas.html){:. extlink} to be used for this table. The schema must exist in the database and be writable by the database user. By default the schema set with `--schema` is used, or `public` if that is not set. |
| data_tablespace  | The [PostgreSQL tablespace](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html){:.extlink} used for the data in this table. |
| index_tablespace | The [PostgreSQL tablespace](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html){:.extlink} used for all indexes of this table. |
| cluster          | Set clustering strategy. Use `"auto"` (default) to enable clustering by geometry, osm2pgsql will choose the best method. Use `"no"` to disable clustering. |
| indexes          | Define indexes to be created on this table. If not set, the default is to create a GIST index on the first (or only) geometry column. |
{: .desc}

All the `osm2pgsql.define*table()` functions return a database table Lua
object. You can call the following functions on it:

| Function         | Description |
| ---------------- | ----------- |
| :name()          | The name of the table as specified in the define function. |
| :schema()        | The schema of the table as specified in the define function. |
| :columns()       | The columns of the table as specified in the define function. |
| :insert(PARAMS)  | Add a row to the database table. See below for details. |
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
"restaurants" table described above, the `osm2pgsql.define_table()` call will
look like this:

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
| tile     | Special case for generalized data stored with tile x and y coordinates. See below. |
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

Osm2pgsql will only create these Id indexes if an updatable database is
created, i.e. if osm2pgsql is run with `--slim` (but not `--drop`). You can set
the optional field `create_index` in the `ids` setting to `'always'` to force
osm2pgsql to always create this index, even in non-updatable databases (the
default is `'auto'`, only create the index if needed for updating).

Generalized data (see [Generalization](#generalization) chapter) is sometimes
stored in tables indexed by x, y tile coordinates. For such tables use the
`tile` value for the `ids` field. Two columns called `x` and `y` with SQL type
`int` will be created (it is not possible to change those column names or the
type). In "create" mode, if the database is updatable or when the
`create_index` option is set to `always`, an index will automatically be
generated on those columns *after* the generalization step is run with
`osm2pgsql-gen`.

#### Unique Ids

It is often desirable to have a unique PRIMARY KEY on database tables. Many
programs need this.

There seems to be a natural unique key, the OSM node, way, or relation ID the
data came from. But there is a problem with that: It depends on the Lua config
file whether a key is unique or not. Nothing prevents you from inserting
multiple rows into the database with the same id. It often makes sense in fact,
for instance when splitting a multipolygon into its constituent polygons.

If you need unique keys on your database tables there are two options: Using
those natural keys and making sure that you don't have duplicate entries. Or
adding an additional ID column. The latter is easier to do and will work in
all cases, but it adds some overhead.

#### Using Natural Keys for Unique Ids

To use OSM IDs as primary keys, you have to make sure that you only ever add a
single row per OSM object to an output table, i.e. do not call `insert`
multiple times on the same table for the same OSM object.

Set the `create_index` option in the `ids` setting (see above) to `'unique'` to
get a `UNIQUE` index instead of the normal non-unique index for the ID column.
*Version >= 2.1.0*{:.version} Set it to `'primary_key'` to define a primary key
for this table instead of just a unique index.

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

You probably also want an index on this column. See the chapter on [Defining
Indexes](#defining-indexes) on how to create this index from osm2pgsql.

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
| sql_type    | The SQL type of the column (Optional, default depends on `type`, see next table). |
| not_null    | Set to `true` to make this a `NOT NULL` column. (Optional, default `false`.) |
| create_only | Set to `true` to add the column to the `CREATE TABLE` command, but do not try to fill this column when adding data. This can be useful for `SERIAL` columns or when you want to fill in the column later yourself. (Optional, default `false`.) |
| projection  | On geometry columns only. Set to the EPSG id or name of the projection. (Optional, default web mercator, `3857`.) |
| expire      | On geometry columns only. Set expire output. See [Defining and Using Expire Outputs](#defining-and-using-expire-outputs) (Optional.) |
{: .desc}

The `type` field describes the type of the column from the point of view of
osm2pgsql, the `sql_type` describes the type of the column from the point of
view of the PostgreSQL database. Usually they are either the same or the
SQL type is derived directly from the `type` according to the following table.
But it is possible to set them individually for special cases.

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
| geometry           | `geometry(GEOMETRY,*SRID*)`           | (\*) |
| point              | `geometry(POINT,*SRID*)`              | (\*) |
| linestring         | `geometry(LINESTRING,*SRID*)`         | (\*) |
| polygon            | `geometry(POLYGON,*SRID*)`            | (\*) |
| multipoint         | `geometry(MULTIPOINT,*SRID*)`         | (\*) |
| multilinestring    | `geometry(MULTILINESTRING,*SRID*)`    | (\*) |
| multipolygon       | `geometry(MULTIPOLYGON,*SRID*)`       | (\*) |
| geometrycollection | `geometry(GEOMETRYCOLLECTION,*SRID*)` | (\*) |
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
type. Correct use of `sql_type` is not easy. Only use `sql_type` if you have
some familiarity with PostgreSQL types and how they are converted from/to text.
If you get this wrong you'll get error messages about "Ending COPY mode" that
are hard to interpret. Considering using the `json` or `jsonb` `type` instead,
for which osm2pgsql does the correct conversions.
{: .note}


#### Defining Geometry Columns

Most tables will have a geometry column. The types of the geometry column
possible depend on the type of the input data. For node tables you are pretty
much restricted to point geometries, but there is a variety of options for
relation tables for instance.

You can have zero, one or more geometry columns. An index will only be built
automatically for the first (or only) geometry column you define. The table
will be [clustered](#clustering-by-geometry) by the first (or only) geometry
column (unless disabled).

The supported geometry types are:

| Geometry type      | Description |
| ------------------ | ----------- |
| point              | Point geometry, usually created from nodes. |
| linestring         | Linestring geometry, usually created from ways. |
| polygon            | Polygon geometry for area tables, created from ways or relations. |
| multipoint         | Currently not used. |
| multilinestring    | Created from (possibly split up) ways or relations. |
| multipolygon       | For area tables, created from ways or relations. |
| geometrycollection | Geometry collection, created from relations. |
| geometry           | Any kind of geometry. Also used for area tables that should hold both polygon and multipolygon geometries. |
{: .desc}

By default geometry columns will be created in web mercator (EPSG 3857). To
change this, set the `projection` parameter of the column to the EPSG code
you want (or one of the strings `latlon(g)`, `WGS84`, or `merc(ator)`, case
is ignored).

Geometry columns can have expire configurations attached to them. See the
section on [Defining and Using Expire
Outputs](#defining-and-using-expire-outputs) for details.

### Defining Indexes

Osm2pgsql will always create indexes on the id column(s) of all tables if the
database is updateable (i.e. in slim mode), because it needs those indexes to
update the database. You can not control those indexes with the settings
described in this section.
{: .note}

To define indexes, set the `indexes` field of the table definition to an array
of Lua tables. If the array is empty, no indexes are created for this table
(except possibly an index on the id column(s)). If there is no `indexes` field
(or if it is set to `nil`) a GIST index will be created on the first (or only)
geometry column of this table.

The following fields can be set in an index definition. You have to set at
least the `method` and either `column` or `expression`.

| Key        | Description |
| ---------- | ----------- |
| column     | The name of the column the index should be created on. Can also be an array of names. Required, unless `expression` is set. |
| name       | Optional name of this index. (Default: Let PostgreSQL choose the name.) |
| expression | A valid SQL expression used for [indexes on expressions](https://www.postgresql.org/docs/current/indexes-expressional.html){:.extlink}. Can not be used together with `column`. |
| include    | A column name or list of column names to include in the index as non-key columns. (Only available from PostgreSQL 11.) |
| method     | The index method ('btree', 'gist', ...). See the [PostgreSQL docs](https://www.postgresql.org/docs/current/indexes-types.html){:.extlink} for available types (required). |
| tablespace | The tablespace where the index should be created. Default is the tablespace set with `index_tablespace` in the table definition. |
| unique     | Set this to `true` or `false` (default). Note that you have to make sure yourself never to add non-unique data to this column. |
| where      | A condition for a [partial index](https://www.postgresql.org/docs/current/indexes-partial.html){:.extlink}. This has to be set to a text that makes valid SQL if added after a `WHERE` in the `CREATE INDEX` command. |
{: .desc}

If you need an index that can not be expressed with these definitions, you have
to create it yourself using [the SQL `CREATE INDEX`
command](https://www.postgresql.org/docs/current/sql-createindex.html){:.extlink}
after osm2pgsql has finished its job.

### Defining and Using Expire Outputs

When osm2pgsql is working in 'append' mode, i.e. when it is updating an
existing database from OSM change files, it can figure out which changes will
potentially affect which Web Mercator tiles, so that you can re-render those
tiles later. See the [Expire chapter](#expire) for some general information
about expiry.

The list of tile coordinates can be written to a file and/or to a database
table. Use the `osm2pgsql.define_expire_output()` Lua function to define an
expire output. The function has a single paramater, a Lua table with the
following fields:

| Field    | Description |
| -------- | ----------- |
| maxzoom  | The maximum zoom level for which tile coordinates are written out. Default: 0. |
| minzoom  | The minimum zoom level for which tile coordinates are written out. Optional. Default is the same as maxzoom. |
| filename | The filename of the output file. Optional. |
| schema   | The database schema for the output table. The schema must exist in the database and be writable by the database user. Optional. By default the schema set with `--schema` is used, or `public` if that is not set. |
| table    | The database table for the output. Optional. |
{: .desc}

You have to supply the `filename` and/or the `table` (possibly with `schema`).
You can provide either or both. The database table will be created for you if
it isn't available already.

Defined expire outputs can then be used in table definitions. Geometry columns
using Web Mercator projection (EPSG 3857) can have an `expire` field which
specifies which expire outputs should be triggered by changes affecting this
geometry.

| Field           | Description |
| --------------- | ----------- |
| output          | The expire output defined with `osm2pgsql.define_expire_output()`. |
| mode            | How polygons are converted to tiles. Can be `full-area` (default), `boundary-only`, or `hybrid`. |
| full_area_limit | In `hybrid` mode, set the maximum area size for which a full-area expiry is done. Above this `boundary-only` is used. |
| buffer          | The size of the buffer around geometries to be expired as a fraction of the tile size. |
{: .desc}

For an example showing how the expire output works, see the
[`flex-config/expire.lua`](https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/flex-config/expire.lua){:.extlink}
example config file.

### Processing Callbacks

You are expected to define one or more of the following functions:

| Callback function                               | Description                                       |
| ----------------------------------------------- | ------------------------------------------------- |
| osm2pgsql.**process_node**(object)              | Called for each new or changed tagged node.       |
| osm2pgsql.**process_way**(object)               | Called for each new or changed tagged way.        |
| osm2pgsql.**process_relation**(object)          | Called for each new or changed tagged relation.   |
| osm2pgsql.**process_untagged_node**(object)     | Called for each new or changed untagged node.     |
| osm2pgsql.**process_untagged_way**(object)      | Called for each new or changed untagged way.      |
| osm2pgsql.**process_untagged_relation**(object) | Called for each new or changed untagged relation. |
{: .desc}

They all have a single argument of type table (here called `object`) and no
return value. If you are not interested in all object types, you do not have
to supply all the functions.

Usually you are only interested in tagged objects, i.e. OSM objects that have
at least one tag, so you will only define one or more of the first three
functions. But if you are interested in untagged objects also, define the
last three functions. If you want to have the same behaviour for untagged
and tagged objects, you can define the functions to be the same.

These functions are called for each new or modified OSM object in the input
file. No function is called for deleted objects, osm2pgsql will automatically
delete all data in your database tables that were derived from deleted objects.
Modifications are handled as deletions followed by creation of a "new" object,
for which the functions are called.

You can do anything in those processing functions to decide what to do with
this data. If you are not interested in that OSM object, simply return from the
function. If you want to add the OSM object to some table call the `insert()`
function on that table.

The parameter table (`object`) has the following fields and functions:

| Field / Function  | Description |
| ----------------- | ----------- |
| .id               | The id of the node, way, or relation. |
| .type             | The object type as string (`node`, `way`, or `relation`). |
| .tags             | A table with all the tags of the object. |
| .version          | Version of the OSM object. (\*) |
| .timestamp        | Timestamp of the OSM object, time in seconds since the epoch (midnight 1970-01-01). (\*) |
| .changeset        | Changeset containing this version of the OSM object. (\*) |
| .uid              | User id of the user that created or last changed this OSM object. (\*) |
| .user             | User name of the user that created or last changed this OSM object. (\*) |
| .is_closed        | Ways only: A boolean telling you whether the way geometry is closed, i.e. the first and last node are the same. |
| .nodes            | Ways only: An array with the way node ids. |
| .members          | Relations only: An array with member tables. Each member table has the fields `type` (values `n`, `w`, or `r`), `ref` (member id) and `role`. |
| :grab_tag(KEY)    | Return the tag value of the specified key and remove the tag from the list of tags. (Example: `local name = object:grab_tag('name')`) This is often used when you want to store some tags in special columns and the rest of the tags in an jsonb or hstore column. |
| :get_bbox()       | Get the bounding box of the current node, way, or relation. This function returns four result values: the lon/lat values for the bottom left corner of the bounding box, followed by the lon/lat values of the top right corner. Both lon/lat values are identical in case of nodes. Example: `lon, lat, dummy, dummy = object:get_bbox()`. Relation members (nested relations) are not taken into account. |
| :as_point()              | Create point geometry from OSM node object. |
| :as_linestring()         | Create linestring geometry from OSM way object. |
| :as_polygon()            | Create polygon geometry from OSM way object. |
| :as_multipoint()         | Create (multi)point geometry from OSM node/relation object. |
| :as_multilinestring()    | Create (multi)linestring geometry from OSM way/relation object. |
| :as_multipolygon()       | Create (multi)polygon geometry from OSM way/relation object. |
| :as_geometrycollection() | Create geometry collection from OSM relation object. |
{: .desc}

These are only available if the OSM input file actually contains those fields.
When handling updates they are only included if the middle table contain this
data (i.e. when `-x|--extra-attributes` option was used).
{: .table-note}

The `as_*` functions will return a NULL geometry if
the geometry can not be created for some reason, for instance a polygon can
only be created from closed ways. This can also happen if your input data is
incomplete, for instance when nodes referenced from a way are missing.
You can check the [geometry object](#geometry-objects-in-lua) for
`is_null()`, for example `object:as_multipolygon():is_null()`.

The `as_linestring()` and `as_polygon()` functions can only be used on ways.

The `as_multipoint()` function can be used on nodes and relations. For nodes it
will always return a point geometry, for relations a point or multipoint
geometry with all available node members.

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

### The `after` Callback Functions

There are three additional processing functions that are sometimes useful:

| Callback function               | Description                               |
| ------------------------------- | ----------------------------------------- |
| osm2pgsql.**after_nodes**()     | Called after all nodes are processed.     |
| osm2pgsql.**after_ways**()      | Called after all ways are processed.      |
| osm2pgsql.**after_relations**() | Called after all relations are processed. |
{: .desc}

OSM data files contain objects in the order nodes, then ways, then relations.
This means you will first get all the `process_(untagged_)node` calls, then
the `after_nodes` call, then all the `process_(untagged_)way` calls, then the
`after_ways` call, then all the `process_(untagged_)relation` calls, and
lastly the `after_relations`call.

All `after_*` callbacks are called at the appropriate place even if there are
no objects of the corresponding type in the input.

### The `insert()` Function

Use the `insert()` function to add data to a previously defined table:

```lua
-- definition of the table:
local table_pois = osm2pgsql.define_node_table('pois', {
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

#### Handling of NULL in `insert()` Function

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
first, then ways, then relations. This means that when the nodes or ways are
read and processed, osm2pgsql can't know yet whether a node or way is in a
relation (or in several). But for some use cases we need to know in which
relations a node or way is and what the tags of these relations are or the
roles of those member ways. The typical case are relations of type `route` (bus
routes etc.) where we might want to render the `name` or `ref` from the route
relation onto the way geometry.

The osm2pgsql flex output supports this use case by adding an additional
"reprocessing" step. Osm2pgsql will call the Lua function
`osm2pgsql.select_relation_members()` for each added, modified, or deleted
relation. Your job is to figure out which node or way members in that relation
might need the information from the relation to be rendered correctly and
return those ids in a Lua table with the 'nodes' and/or 'ways' fields. This is
usually done with a function like this:

```lua
function osm2pgsql.select_relation_members(relation)
    if relation.tags.type == 'route' then
        return {
            nodes = {},
            ways = osm2pgsql.way_member_ids(relation)
        }
    end
end
```

Instead of using the helper function `osm2pgsql.way_member_ids()` which returns
the ids of all way members (or the analog `osm2pgsql.node_member_ids()`
function), you can write your own code, for instance if you want to check the
roles.

Note that `select_relation_members()` is called for deleted relations and for
the old version of a modified relation as well as for new relations and the
new version of a modified relation. This is needed, for instance, to correctly
mark member ways of deleted relations, because they need to be updated, too.
The decision whether a node/way is to be marked or not can only be based on the
tags of the relation and/or the roles of the members. If you take other
information into account, updates might not work correctly.

In addition you have to store whatever information you need about the relation
in your `process_relation()` function in a global variable.

Make sure you use `select_relation_members()` *only for deciding which
nodes/ways to reprocess*, do not store information about the relations from
that function, it will not work with updates. Use the `process_relation()`
function instead.
{:.note}

After all relations are processed, osm2pgsql will reprocess all marked
nodes/ways by calling the `process_node()` and `process_way()` functions,
respectively, for them again. This time around you have the information from
the relation in the global variable and can use it.

If you don't mark any nodes or ways, nothing will be done in this reprocessing
stage.

(It is currently not possible to mark relations. This might or might not be
added in future versions of osm2pgsql.)

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

The `insert()` function will try its best to convert Lua values into
corresponding PostgreSQL values. But not all conversions make sense. Here are
the detailed rules:

1. Lua values of type `function`, `userdata`, or `thread` will always result in
   an error.
2. The Lua type `nil` is always converted to `NULL`.
3. If the result of a conversion is `NULL` and the column is defined as `NOT
   NULL` the data is not inserted, see
   [above](#handling-of-null-in-insert-function) for details.
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
9. For `json` and `jsonb` columns string, number, and boolean values are
   converted to their JSON equivalent as you would expect. (The special
   floating point numbers `NaN` and `Inf` can not be represented in JSON and
   are converted to `null`). An empty table is converted to an (empty) JSON
   object, tables that only have consecutive integer keys starting from 1 are
   converted into JSON arrays. All other tables are converted into JSON
   objects. Mixed key types are not allowed. Osm2pgsql will detect loops in
   tables and return an error.
10. For text columns and any other not specially recognized column types,
    booleans result in an error and numbers are converted to strings.
11. Geometry objects are converted to their PostGIS counterparts. Null
    geometries are converted to database `NULL`. Geometries in WGS84 will
    automatically be transformed into the target column SRS if needed.
    Non-multi geometries will automatically be transformed into
    multi-geometries if the target column has a multi-geometry type.

If you want any other conversions, you have to do them yourself in your Lua
code. Osm2pgsql provides some helper functions for other conversions, see
the Lua helper library ([Appendix B](#lua-library-for-flex-output)).

### Geometry Objects in Lua

Lua geometry objects are created by calls such as `object:as_point()` or
`object:as_polygon()` inside processing functions. It is not possible to
create geometry objects from scratch, you always need an OSM object.

You can write geometry objects directly into geometry columns in the database
using the table `insert()` function. But you can also transform geometries in
multiple ways.

Geometry objects have the following functions. They are modelled after the
PostGIS functions with equivalent names.

| Function                        | Description |
| ------------------------------- | ----------- |
| :area()                         | Returns the area of the geometry calculated on the projected coordinates. The area is calculated using the SRS of the geometry, the result is in map units. For any geometry type but (MULTI)POLYGON the result is always `0.0`. (See also `:spherical_area()`.) |
| :centroid()                     | Return the centroid (center of mass) of a geometry. Implemented for all geometry types. |
| :get_bbox()                     | Get the bounding box of this geometry. This function returns four result values: the lon/lat values for the bottom left corner of the bounding box, followed by the lon/lat values of the top right corner. Both lon/lat values are identical in case of points. Example: `lon, lat, dummy, dummy = object:as_polygon():centroid():get_bbox()`. If possible use the `get_bbox()` function on the OSM object instead, it is more efficient. |
| :geometries()                   | Returns an iterator for iterating over member geometries of a multi-geometry. See below for detail. |
| :geometry_n()                   | Returns the nth geometry (1-based) of a multi-geometry. |
| :geometry_type()                | Returns the type of geometry as a string: `NULL`, `POINT`, `LINESTRING`, `POLYGON`, `MULTIPOINT`, `MULTILINESTRING`, `MULTIPOLYGON`, or `GEOMETRYCOLLECTION`.
| :is_null()                      | Returns `true` if the geometry is a NULL geometry, `false` otherwise. |
| :length()                       | Returns the length of the geometry. For any geometry type but (MULTI)LINESTRING this is always `0.0`. The length is calculated using the SRS of the geometry, the result is in map units. |
| :line_merge()                   | Merge lines in a (MULTI)LINESTRING as much as possible into longer lines. |
| :num_geometries()               | Returns the number of geometries in a multi-geometry. Always 0 for NULL geometries and always 1 for non-multi geometries. |
| :pole_of_inaccessibility(opts)  | Calculate "pole of inaccessibility" of a polygon, a point farthest away from the polygon boundary, sometimes called the center of the maximum inscribed circle. Note that for performance reasons this is an approximation. It is intended as a reasonably good labelling point. One optional parameter *opts*, which must be a Lua table with options. The only option currently defined is `stretch`. If this is set to a value larger than 1 an ellipse instead of a circle is inscribed. This might be useful for labels which usually use more space horizontally. Use a value between 0 and 1 for a vertical ellipse. |
| :segmentize(max_segment_length) | Segmentize a (MULTI)LINESTRING, so that no segment is longer than `max_segment_length`. Result is a (MULTI)LINESTRING. |
| :simplify(tolerance)            | Simplify (MULTI)LINESTRING geometries with the Douglas-Peucker algorithm. (Currently not implemented for other geometry types.) |
| :spherical_area()               | Returns the area of the geometry calculated on the spheroid. The geometry must be in WGS 84 (4326). For any geometry type but (MULTI)POLYGON the result is always `0.0`. The result is in m². (See also `:area()`.) |
| :srid()                         | Return SRID of the geometry. |
| :transform(target_srid)         | Transform the geometry to the target SRS. |
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
Github](https://github.com/osm2pgsql-dev/osm2pgsql/discussions).

### Locators

*Version >= 2.2.0*{:.version} This feature is only available from version 2.2.0.

When processing OSM data it is often useful to know in which area some OSM
object is. Maybe you want to draw specific highway shields in each state. Or
you want to transliterate labels in different ways depending on the country the
label is in. Or draw features differently depending on whether they are inside
a national park or outside. Or set different default values for speed limits
based on the country a highway is in. To do this you can use a *locator*.

A *locator* is initialized with one or more *regions*, each region has a name
and a polygon or bounding box. A geometry of an OSM object can then be checked
against this list of regions to figure out in which region(s) it is located.

Locators are created in Lua with `define_locator()`:

```lua
local countries = osm2pgsql.define_locator({ name = 'countries' })
```

The name of the locator is used for informational and error messages only. You
can have as many locators as you want, they work independently of each other.

Bounding boxes can be added to a locator with `add_bbox()`. Use the longitude
and latitude of the lower left and upper right corners of the box as
parameters:

```lua
local extract = osm2pgsql.define_locator({ name = 'extract' })
extract:add_bbox('inside', -32.35, 62.22, -7.35, 68.16)
```

Polygons can be added from the database by calling `add_from_db()` and
specifying a SQL query which can return any number of rows, each defining a
region with the name and the (multi)polygon as columns:

```lua
local extract = osm2pgsql.define_locator({ name = 'extract' })
extract:add_from_db("SELECT country_code, geom FROM countries")
```

The name can be any string (or anything the database can convert to a string
when reading the data), for instance the name of a country or an ISO country
code. You can have multiple regions with the same name, but you can not
differentiate between them later. The geometry must be in WGS84 (EPSG:4326).

You can get region data from OSM or any other source, you'll just have to
import it into the database before running osm2pgsql. If you want to use
OSM data, you can run osm2pgsql twice, once with a config file importing
only the polygons and then with your normal config which reads the just
imported data into a locator.

A locator can then be queried in the callbacks using `all_intersecting()` which
returns a list of names of all regions that intersect the specified OSM object
geometry. The results are not in any specific order.

```lua
local country_codes = extract:all_intersecting(object:as_point())
```

If the result is an empty array (Lua table), the object isn't in any of the
regions. (You can check for that with `if #country_codes == 0 then ...`).

Or you can use the function `first_intersecting()` which only returns a single
region for those cases where there can be no overlapping data or where the
details of objects straddling region boundaries don't matter. It is faster
than `all_intersecting()` because the search returns after the first region
is found.

```lua
local cc = extract:first_intersecting(object:as_linestring())
```

The result is `nil` if the geometry isn't in any of the regions.

Several example config files are provided in the
[flex-config/locator](https://github.com/osm2pgsql-dev/osm2pgsql/tree/master/flex-config/locator)
directory of the source code repository.

#### Locator Performance

Working with a Locator while the data is being loaded into the database is much
faster than to do the same operations inside the database after the import.

You can have hundreds of thousands of regions in a locator, osm2pgsql handles
that fine. Checking each OSM object against a list of all OSM country
boundaries works just fine, even when importing a full planet.

Because the region polygons are stored in an
[R-tree](https://en.wikipedia.org/wiki/R-tree){:.extlink} internally, the
biggest performance problem comes from very large polygons. It is much better
to separate the polygons inside a multipolygon (for instance using
[ST_Dump](https://postgis.net/docs/manual-3.3/ST_Dump.html){:.extlink}) and to
split polygons into smaller chunks (for instance using the
[ST_SubDivide](https://postgis.net/docs/manual-3.3/ST_Subdivide.html){:.extlink}
function):

```lua
local extract = osm2pgsql.define_locator({ name = 'extract' })
extract:add_from_db([[
WITH polys AS (
    SELECT cc, (ST_Dump(geom)).geom AS geom FROM countries
)
SELECT cc, ST_Subdivide(geom, 200) FROM polys")
]])
```

It can take a while to compute the subdivision. So if you run osm2pgsql often,
compute the subdivision once and store the result in an extra table and just
load that from osm2pgsql.

