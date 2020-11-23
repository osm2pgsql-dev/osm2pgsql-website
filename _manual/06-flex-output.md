---
chapter: 6
title: The Flex Output
---

*Version >= 1.3.0*{: .version} The *flex* output appeared first in version
1.3.0 of osm2pgsql.

The Flex output is experimental. Everything in here is subject to change.
{: .note}

The *flex* output, as the name suggests, allows for a flexible configuration
that tells osm2pgsql what OSM data to store in your database and exactly where
and how. It is configured through a Lua file which

* defines the structure of the output tables and
* defines functions to map the OSM data to the database data format

Use the `-s, --style=FILE` option to specify the name of the Lua file.

Unlike the pgsql output, the flex output doesn't use command line options
for configuration, but the Lua config file only.
{: .note}

### The Style File

The flex style file is a Lua script. You can use all the power of the [Lua
language](https://www.lua.org/){:.extlink}. This description assumes that you
are somewhat familiar with the Lua language, but it is pretty easy to pick up
the basics and you can use the example config files in the
[`flex-config`](https://github.com/openstreetmap/osm2pgsql/tree/master/flex-config){:.extlink}
directory which contain lots of comments to get you started.

All configuration is done through the `osm2pgsql` global object in Lua. It has
the following fields and functions:

| Field / Function  | Description |
| ----------------- | --- |
| version           | The version of osm2pgsql as a string. |
| mode              | Either `"create"` or `"append"` depending on the command line options (`-c, --create` or `-a, --append`). |
| stage             | Either `1` or `2` (1st/2nd stage processing of the data). See below. |
| define_node_table(NAME, COLUMNS[, OPTIONS])     | Define a node table. |
| define_way_table(NAME, COLUMNS[, OPTIONS])      | Define a way table. |
| define_relation_table(NAME, COLUMNS[, OPTIONS]) | Define a relation table. |
| define_area_table(NAME, COLUMNS[, OPTIONS])     | Define an area table. |
| define_table(OPTIONS)                           | Define a table. This is the more flexible function behind all the other `define_*_table()` functions. It gives you more control than the more convenient other functions. |
{: .desc}

Osm2pgsql also provides some additional functions in the
Lua helper library described in [Appendix B](#lua-library-for-flex-output).

#### Defining a Table

You have to define one or more database tables where your data should end up.
(In create mode, osm2pgsql will create those tables for you in the database.)
This is done with the `osm2pgsql.define_table()` function or, more commonly,
with one of the slightly more convenient functions
`osm2pgsql.define_(node|way|relation|area)_table()`:

```
osm2pgsql.define_(node|way|relation|area)_table(NAME, COLUMNS[, OPTIONS])
```

Here `NAME` is the name of the table, `COLUMNS` is a list of Lua tables
describing the columns as documented below. `OPTIONS` is a Lua table with
options for the table as a whole. An example might be more helpful:

```lua
local restaurants = osm2pgsql.define_node_table('restaurants', {
    { column = 'name', type = 'text' },
    { column = 'tags', type = 'hstore' },
    { column = 'geom', type = 'point' }
})
```

In this case we are creating a table that is intended to be filled with OSM
nodes, the table called `restaurants` will be created in the database with four
colums: A `name` column of type `text` (which will presumably later be filled
with the name of the restaurant), a column called `tags` with type `hstore`
(which will presumable be filled later with all tags of a node), a column
called `geom` which will contain the Point geometry of the node and an Id
column called `node_id`.

Each table is either a *node table*, *way table*, *relation table*, or *area
table*. This means that the data for that table comes primarily from a node,
way, relation, or area, respectively. Osm2pgsql makes sure that the OSM object
id will be stored in the table so that later updates to those OSM objects (or
deletions) will be properly reflected in the tables. Area tables are special,
they can contain data derived from ways and from (multipolygon) relations.

Sometimes the `define_(node|way|relation|area)_table()` functions are a bit to
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
| schema           | Set the [PostgreSQL schema](https://www.postgresql.org/docs/current/ddl-schemas.html){:. extlink} to be used for this table. The schema must exist in the database before you start osm2pgsql. By default no schema is set which usually means the tables will be created in the `public` shema. |
| data_tablespace  | The [PostgreSQL tablespace](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html){:.extlink} used for the data in this table. |
| index_tablespace | The [PostgreSQL tablespace](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html){:.extlink} used for all indexes of this table. |
{: .desc}

All the `osm2pgsql.define*table()` functions return a database table Lua
object. You can call the following functions on it:

| Function  | Description |
| --------- | ----------- |
| name()    | The name of the table as specified in the define function. |
| schema()  | The schema of the table as specified in the define function. |
| columns() | The columns of the table as specified in the define function. |
| add_row() | Add a row to the database table. See below for details. |
{: .desc}

#### Id Handling

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
        { column = 'tags', type = 'hstore' },
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

For its own use, osm2pgsql does not need unique ids. Usually ids are unique in
a given table, but there are several cases where this might not be the case:

1. If you call the `add_row()` function several times on the same table from
   within the same callback.
2. If you are using the `split_at` option on the geometry transformation (see
   below).
3. *Version == 1.3.0*{: .version} If you don't set `multi = true` in the
   area geometry transformation.

If you need unique ids for some reason you can always add your own id column
as `create_only` column with something like this:

```lua
...
    { column = 'myid', type = 'SERIAL', not_null = true, create_only = true },
...
```

This column will be created by osm2pgsql but otherwise ignored. The `SERIAL`
type is [a special type recognized by PostgreSQL](
https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL){: .extlink}
which will generate an autoincrementing id column. You might want to add an
index to this column yourself after osm2pgsql has imported the data.

#### Defining Columns

In the table definitions the columns are specified as a list of Lua tables
with the following keys:

| Key         | Description |
| ----------- | ----------- |
| column      | The name of the PostgreSQL column (required). |
| type        | The type of the column as described above (required). |
| not_null    | Set to `true` to make this a `NOT NULL` column. (Optional, default `false`.) |
| create_only | Set to `true` to add the column to the `CREATE TABLE` command, but do not try to fill this column when adding data. This can be useful for `SERIAL` columns or when you want to fill in the column later yourself. (Optional, default `false`.) |
| projection  | On geometry columns only. Set to the EPSG id or name of the projection. (Optional, default web mercator, `3857`.) |
{: .desc}

#### Defining Geometry Columns

Most tables will have a geometry column. (Currently only zero or one geometry
columns are supported.) The types of the geometry column possible depend on
the type of the input data. For node tables you are pretty much restricted
to point geometries, but there is a variety of options for relation tables
for instance.

The supported geometry types are:

| Geometry type   | Description |
| --------------- | ----------- |
| point           | Point geometry, usually created from nodes. |
| linestring      | Linestring geometry, usually created from ways. |
| polygon         | Polygon geometry for area tables, created from ways or relations. |
| multipoint      | Currently not used. |
| multilinestring | Created from (possibly split up) ways or relations. |
| multipolygon    | For area tables, created from ways or relations. |
| geometry        | Any kind of geometry. Also used for area tables that should hold both polygon and multipolygon geometries. |
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

#### Defining Other Columns

In addition to id and geometry columns, each table can have any number of
"normal" columns using any type supported by PostgreSQL. Some types are
specially recognized by osm2pgsql: `text`, `boolean`, `int2` (`smallint`),
`int4` (`int`, `integer`), `int8` (`bigint`), `real`, `hstore`, and
`direction`. See the [Type Conversion](#type-conversions){:.extlink} section
for details on how this type affects the conversion of OSM data to the
database types.

Instead of the above types you can use any SQL type you want. If you do that
you have to supply the PostgreSQL string representation for that type when
adding data to such columns (or Lua `nil` to set the column to `NULL`). This
can be used, for instance, to create JSON(B) columns. You have to provide valid
JSON from your Lua script in this case. See the example config
[places.lua](https://github.com/openstreetmap/osm2pgsql/blob/master/flex-config/places.lua){:.
extlink} for how this can be done.

#### Processing Callbacks

You are expected to define one or more of the following functions:

| Callback function                  | Description |
| ---------------------------------- | --- |
| osm2pgsql.process_node(object)     | Called for each new or changed node. |
| osm2pgsql.process_way(object)      | Called for each new or changed way. |
| osm2pgsql.process_relation(object) | Called for each new or changed relation. |
{: .desc}

They all have a single argument of type table (here called `object`) and no
return value. If you are not interested in all object types, you do not have
to supply all the functions.

These functions are called for each new or modified OSM object in the input
file. No function is called for deleted objects, osm2pgsql will automatically
delete all data in your database tables that derived from deleted objects.
Modifications are handled as deletions followed by creation of a "new" object,
for which the functions are called.

The parameter table (`object`) has the following fields and functions:

| Field / Function | Description |
| ------------- | ---|
| id            | The id of the node, way, or relation. |
| tags          | A table with all the tags of the object. |
| version       | Version of the OSM object. (\*) |
| timestamp     | Timestamp of the OSM object, time in seconds since the epoch (midnight 1970-01-01). (\*) |
| changeset     | Changeset containing this version of the OSM object. (\*) |
| uid           | User id of the user that created or last changed this OSM object. (\*) |
| user          | User name of the user that created or last changed this OSM object. (\*) |
| grab_tag(KEY) | Return the tag value of the specified key and remove the tag from the list of tags. (Example: `local name = object:grab_tag('name')`) This is often used when you want to store some tags in special columns and the rest of the tags in an hstore column. |
| get_bbox()    | Get the bounding box of the current node or way. This function returns four result values: the lot/lat values for the bottom left corner of the bounding box, followed by the lon/lat values of the top right corner. Both lon/lat values are identical in case of nodes. Example: `lon, lat, dummy, dummy = object.get_bbox()` (This function doesn't work for relations currently.) |
| is_closed     | Ways only: A boolean telling you whether the way geometry is closed, i.e. the first and last node are the same. |
| nodes         | Ways only: An array with the way node ids. |
| members       | Relations only: An array with member tables. Each member table has the fields `type` (values `n`, `w`, or `r`), `ref` (member id) and `role`. |
{: .desc}

These are only available if the `-x|--extra-attributes` option is used and the
OSM input file actually contains those fields.
{: .table-note}

You can do anything in those processing functions to decide what to do with
this data. If you are not interested in that OSM object, simply return from the
function. If you want to add the OSM object to some table call the `add_row()`
function on that table:

```lua
-- definition of the table:
table_pois = osm2pgsql.define_node_table('pois', {
    { column = 'tags', type = 'hstore' },
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
details.

Note that you can't set the object id, this will be handled for you behind the
scenes.

### Geometry Transformations

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

The `add_row()` command will try its best to convert Lua values into
corresponding PostgreSQL values. But not all conversions make sense. Here
are the detailed rules:

1. Lua values of type `function`, `userdata`, or `thread` will always result in
   an error.
2. The Lua type `nil` is always converted to `NULL`.
3. If the result of a conversion is `NULL` and the column is defined as `NOT
   NULL`, an error is thrown.
4. The Lua type `table` is converted to the PostgreSQL type `hstore` if and
   only if all keys and values in the table are string values. A Lua `table`
   can not be converted to any other PostgreSQL type.
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
9. For text columns and any other not specially recognized column types,
   booleans result in an error and numbers are converted to strings.

If you want any other conversions, you have to do them yourself in your Lua
code. Osm2pgsql provides some helper functions for other conversions, see
the Lua helper library ([Appendix B](#lua-library-for-flex-output)).
