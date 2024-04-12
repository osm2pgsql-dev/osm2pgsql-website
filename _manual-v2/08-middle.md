---
chapter: 8
title: Middle
---

The middle keeps track of all OSM objects read by osm2pgsql and the
relationships between those objects. It knows, for instance, which nodes are
used by which ways, or which members a relation has. It also keeps track of
all node locations. This information is necessary to build way geometries from
way nodes and relation geometries from members and it is necessary when
updating data, because OSM change files only contain changed objects themselves
and not all the related objects needed for creating an object's geometry.

### The Properties Table

Osm2pgsql stores some *properties* into a
database table. This table is always called `osm2pgsql_properties`. It will
be created in the schema set with the `--middle-schema` option, or the `public`
schema by default.

The properties table tracks some settings derived from the command line options
and from the input file(s). It allows osm2pgsql to make sure that updates are
run with compatible options.

The `osm2pgsql_properties` table contains two columns: The `property` column
contains the name of a property and the `value` column its value. Properties
are always stored as strings, for boolean properties the strings `true` and
`false` are used.

The following properties are currently defined:

| Property                      | Type   | Description |
| ----------------------------- | ------ | ----------- |
| `attributes`                  | bool   | Import with OSM attributes (i.e. osm2pgsql was run with `-x` or `--extra-attributes`)? |
| `current_timestamp`           | string | Largest timestamp of any object in any of the input file(s) in ISO format (`YYYY-mm-ddTHH:MM:SSZ`). Updated with each data update. |
| `db_format`                   | int    | 0 = not updatable, 1 = legacy format (not supported any more), 2 = current format. |
| `flat_node_file`              | string | Absolute filename of the flat node file (specified with `-F` or `--flat-nodes`). See below for some details. |
| `import_timestamp`            | string | Largest timestamp of any object in the in the input file(s) in ISO format (`YYYY-mm-ddTHH:MM:SSZ`). Only set for initial import. |
| `output`                      | string | The output as set with the `-O` or `--output` option. |
| `prefix`                      | string | Table name prefix set with `-p` or `--prefix`. |
| `replication_base_url`        | string | For replication (see below). |
| `replication_sequence_number` | string | For replication (see below). |
| `replication_timestamp`       | string | For replication (see below). |
| `style`                       | string | The style file as set with the `-S` or `--style` option. See below for some details. |
| `updatable`                   | bool   | Is this database updatable (imported with `--slim` and without `--drop`)? |
| `version`                     | string | Version number of the osm2pgsql application that did the import. |
{: .desc}

When updating an existing database that has an `osm2pgsql_properties` table,
osm2pgsql will check that the command line options used are compatible and will
complain if they are not. Options that are not set on the command line will
automatically be set if needed. So for instance if you import a database
without `-x` but then use `-x` on updates, osm2pgsql will fail with an error
message. If you use `-x` both on import and on update everything is fine. And
if you use `-x` on import but not on update, osm2pgsql will detect that you
used that option on import and also use it on update.

The name of the flat node and style files specified on the command line are
converted to absolute file names and stored in the `flat_node_file` and `style`
property, respectively. That means that osm2pgsql will find the files again
even if you start it from a different current working directory. If you need to
move the flat node or style file somewhere else, you can do that. The next time
you run osm2pgsql, add the `-F, --flat-nodes` or `-S, --style` option again with
the new file name and osm2pgsql will use the new name and update the properties
table accordingly.

The `current_timestamp` and `import_timestamp` properties are not set if the
input file(s) don't contain timestamps on the OSM objects. (Timestamps in
OSM files are optional, but most OSM files have them.)

The `replication_*` properties reflect the setting of the respective header
fields in the input file on import and are used by
[osm2pgsql-replication](#updating-an-existing-database) to automatically update
the database. That program will also update those fields. If you import
multiple files, these properties will not be set.

The contents of the `osm2pgsql_properties` table are internal to osm2pgsql and
you should never change them. There is one exception: You can add your own
properties for anything you need, but make sure to start the property names
with an underscore (`_`). this way the property names will never clash with any
names that osm2pgsql might introduce in the future.

### Database Structure

The middle stores its data in the database in the following tables. The
`PREFIX` can be set with the `-p, --prefix` option, the default is
`planet_osm`. (Note that this option is also interpreted by the pgsql output!)

| Table        | Description   |
| ------------ | ------------- |
| PREFIX_nodes | OSM nodes     |
| PREFIX_ways  | OSM ways      |
| PREFIX_rels  | OSM relations |
| PREFIX_users | OSM users     |
{:.desc}

If a flat node file is used (see below) the `PREFIX_nodes` table might be
missing or empty, because nodes are stored in the flat node file instead. The
users table is only used when the `-x, --extra-attributes` command line option
is set (see below).

The tables have the following structure:

| Column       | Type              | Description |
| ------------ | ----------------- | ----------- |
| id           | `int8 NOT NULL`   | Unique OSM id of this object. Primary key. |
| lat          | `int4 NOT NULL`   | (Nodes only) Latitude * 10<sup>7</sup>. |
| lon          | `int4 NOT NULL`   | (Nodes only) Longitude * 10<sup>7</sup>. |
| nodes        | `int8[] NOT NULL` | (Ways only) Array of node ids. |
| members      | `jsonb NOT NULL`  | (Relations only) Contains all relation members, for the format see below. |
| tags         | `jsonb`           | Tags of this OSM object in the obvious key/value format. |
{:.desc}

You can create a PostGIS geometry from the `lat` and `lon` columns like this:

```{sql}
SELECT id, ST_SetSRID(ST_MakePoint(lon / 10000000.0, lat / 10000000.0), 4326) AS geom FROM planet_osm_nodes;
```

#### The `members` Column

The members column contains a JSON array of JSON objects. For each member the
JSON object contains the following fields:

| Field | Type    | Description |
| ----- | ------- | ----------- |
| type  | Char    | Single character `N`, `W`, or `R` for the OSM object type node, way, or relation. |
| ref   | Integer | The OSM id of the member. |
| role  | Text    | The role of the member. |
{:.desc}

A function `planet_osm_member_ids(members int8[], type char(1))` is provided.
(The prefix is the same as the tables, here `planet_osm`.) The function returns
all ids in `members` of type `type` ('N', 'W', or 'R') as an array of int8. To
get the ids of all way members of relation 17, for instance, you can use it like
this:

```{sql}
SELECT planet_osm_member_ids(members, 'W') AS way_ids
    FROM planet_osm_rels WHERE id = 17;
```

#### Extra Attributes

The following extra columns are stored when osm2pgsql is run with the `-x,
--extra-attributes` command line option (all columns can be `NULL` if the
respective fields were not set in the input data):

| Column       | Type                     | Description |
| ------------ | ------------------------ | ----------- |
| created      | timestamp with time zone | Timestamp when this version of the object was created. |
| version      | int4                     | Version number of this object. |
| changeset_id | int4                     | Id of the changeset that contains this object version. |
| user_id      | int4                     | User id of the user who created this object version. |
{:.desc}

In addition the `PREFIX_users` table is created with the following structure:

| Column | Type | Description                  |
| ------ | ---- | ---------------------------- |
| id     | int4 | Unique user id. Primary key. |
| name   | text | User name (`NOT NULL`).      |
{:.desc}

#### Indexes

PostgreSQL will automatically create BTREE indexes for primary keys on all
middle tables. In addition there are the following indexes:

An GIN index on the `nodes` column of the `ways` table allows you to find all
ways referencing a give node. You need to access this index with a query like
this (which finds all ways referencing node 123):

```{sql}
SELECT * FROM planet_osm_ways
    WHERE nodes && ARRAY[123::int8]
    AND planet_osm_index_bucket(nodes) && planet_osm_index_bucket(ARRAY[123::int8]);
```

Note the extra condition using the `planet_osm_index_bucket()` function which
makes sure the index can be used. The function will have the same prefix as
your tables (by default `planet_osm`).

To find the relations referencing specific nodes or ways use the
`planet_osm_member_ids()` function described [above](#the-members-column).
There are indexes for members of type node and way (but not members of type
relation) provided which use this function. Use a query like this:

```{sql}
SELECT * FROM planet_osm_rels
    WHERE planet_osm_member_ids(members, 'W'::char(1)) && ARRAY[456::int8];
```

Make sure to use the right casts (`::char(1)` for the type, `::int8` for the
ids), without them PostgreSQL sometimes is not able to match the queries to
the right functions and indexes.

By default there is no index on the `tags` column. If you need this, you can
create it with

```{sql}
CREATE INDEX ON planet_osm_nodes USING gin (tags) WHERE tags IS NOT NULL;
```

Such an index will support queries like

```{sql}
SELECT id FROM planet_osm_nodes WHERE tags ? 'amenity'; -- check for keys
SELECT id FROM planet_osm_nodes WHERE tags @> '{"amenity":"post_box"}'::jsonb; -- check for tags
```

#### Reserved Names and Compatibility

For compatibility with older and future versions of osm2pgsql you should never
create tables, indexes, functions or any other objects in the database with
names that start with `osm2pgsql_` or with the `PREFIX` you have configured
(`planet_osm_` by default). This way your objects will not clash with any
objects that osm2pgsql creates.

Always read the release notes before upgrading in case osm2pgsql changes the
format or functionality of any tables, indexes, functions or other objects in
the database that you might be using.

### Flat Node Store

`-F` or `--flat-nodes` specifies that instead of a table in PostgreSQL, a binary
file is used as a database of node locations. This should only be used on full
planet imports or very large extracts (e.g. Europe) but in those situations
offers significant space savings and speed increases, particularly on
mechanical drives.

The file will need approximately `8 bytes * maximum node ID`, regardless of the
size of the extract. With current OSM data (in 2024) that's about 100 GB.
As a good rule of thumb you can look at the current PBF planet file [on
planet.osm.org](https://planet.openstreetmap.org/), the flat node file will
probably be somewhat larger than that.

If you are using the `--drop` option, the flat node file will be deleted
after import.

### Caching

In slim-mode, i.e. when using the database middle, you can use the `-C,
--cache` option to specify how much memory (in MBytes) to allocate for caching
data. Generally more cache means your import will be faster. But keep in mind
that other parts of osm2pgsql and the database will also need memory.

To decide how much cache to allocate, the rule of thumb is as follows: use the
size of the PBF file you are trying to import or about 75% of RAM, whatever is
smaller. Make sure there is enough RAM left for PostgreSQL. It needs at least
the amount of `shared_buffers` given in its configuration.

You may also set `--cache` to 0 to disable caching completely to save memory.
If you use a flat node store you should disable the cache, it will usually not
help in that situation.

In non-slim mode, i.e. when using the RAM middle, the `--cache` setting is
ignored. All data is stored in RAM and uses however much memory it needs.

### Bucket Index for Slim Mode

Osm2pgsql can use an index for way node lookups in slim mode that needs a lot
less disk space than earlier versions did. For a planet the savings can be
about 200 GB! Because the index is so much smaller, imports are faster, too.
Lookup times are slightly slower, but this shouldn't be an issue for most
people.

*If you are not using slim mode and/or not doing updates of your database, this
does not apply to you.*

### Middle Command Line Options

{% include_relative options/middle.md %}
