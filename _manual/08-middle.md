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

*Version >= 1.9.0*{: .version} Osm2pgsql stores some *properties* into a
database table. This table is always called `osm2pgsql_properties`. It will
be created in the schema set with the `--middle-schema` option, or the `public`
schema by default.

The properties table tracks some settings derived from the command line options
and from the input file(s). It allows osm2pgsql to make sure that updates are
run with compatible options. Versions before 1.9.0 do not create this table
and so they don't offer the checks specified below.

The `osm2pgsql_properties` table contains two columns: The `property` column
contains the name of a property and the `value` column its value. Properties
are always stored as strings, for boolean properties the strings `true` and
`false` are used.

The following properties are currently defined:

| Property                      | Type   | Description |
| ----------------------------- | ------ | ----------- |
| `attributes`                  | bool   | Import with OSM attributes (i.e. osm2pgsql was run with `-x` or `--extra-attributes`)? |
| `current_timestamp`           | string | Largest timestamp of any object in any of the input file(s) in ISO format (`YYYY-mm-ddTHH:MM:SSZ`). Updated with each data update. |
| `flat_node_file`              | string | Absolute filename of the flat node file (specified with `--flat-nodes`). See below for some details. |
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
you run osm2pgsql, add the `--flat-nodes` or `-S, --style` option again with
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
you should never change them. Theres is one exception: You can add your own
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

Note that if a flat node file is used (see below) the `PREFIX_nodes` table
might be missing or empty, because nodes are stored in the flat node file
instead. The users table is only used in the new database format and when the
`-x, --extra-attributes` command line option is used (see below).

Historically the names and structure of these tables, colloquially referred to
as "slim tables", are an internal implementation detail of osm2pgsql that users
should not rely on. We are currently in the process of moving from the `legacy`
table format to the `new` format which is designed to be easier to use also for
users.

*Version < 1.9.0*{: .version} Only the `legacy` format is available.

*Version == 1.9.0*{: .version} The `legacy` format is the default. The `new`
format is experimental. To set the format use the
`--middle-database-format=FORMAT` command line option on import (in "create
mode"). For updates (in "append mode") the database format will be
autodetected.

The details of the legacy format are not documented, you should not rely on
that format. In the new format the tables have the following structure (all
columns are `NOT NULL`):

| Column       | Type   | Description |
| ------------ | ------ | ----------- |
| id           | int8   | Unique OSM id of this object. Primary key. |
| lat          | int4   | (Nodes only) Latitude * 10<sup>7</sup>. |
| lon          | int4   | (Nodes only) Longitude * 10<sup>7</sup>. |
| nodes        | int8[] | (Ways only) Array of node ids. |
| members      | jsonb  | (Relations only) Contains all relation members, for the format see below. |
| tags         | jsonb  | Tags of this OSM object in the obvious key/value format. |
{:.desc}

You can create a PostGIS geometry from the `lat` and `lon` columns like this:

```{sql}
SELECT id, ST_SetSRID(ST_MakePoint(lat / 10000000.0, lon / 10000000.0), 4326) AS geom FROM planet_osm_nodes;
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
ways referencing a give node. If you are using a bucket index (which is the
default, see [below](#bucket-index-for-slim-mode)) you need to access this
index with a query like this (which finds all ways referencing node 123):

```{sql}
SELECT * FROM planet_osm_ways
    WHERE nodes && ARRAY[123::int8]
    AND planet_osm_index_bucket(nodes) && planet_osm_index_bucket(ARRAY[123::int8]);
```

Note the extra condition using the `planet_osm_index_bucket()` function which
makes sure the index can be used. The function will have the same prefix as
your tables (by default `planet_osm`).

Without the bucket index, use a query like this:

```{sql}
SELECT * FROM planet_osm_ways WHERE nodes && ARRAY[123::int8];
```

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

`--flat-nodes` specifies that instead of a table in PostgreSQL, a binary
file is used as a database of node locations. This should only be used on full
planet imports or very large extracts (e.g. Europe) but in those situations
offers significant space savings and speed increases, particularly on
mechanical drives.

The file will need approximately `8 bytes * maximum node ID`, regardless of the
size of the extract. With current OSM data (in 2023) that's more than 80 GiB.
As a good rule of thumb you can look at the current PBF planet file [on
planet.osm.org](https://planet.openstreetmap.org/), the flat node file will
probably be somewhat larger than that.

If you are using the `--drop` option, the flat node file will be deleted
after import.

### Caching

In slim-mode, i.e. when using the database middle, you can use the `--cache`
option to specify how much memory (in MBytes) to allocate for caching data.
Generally more cache means your import will be faster, but the memory will
also be needed for other parts of osm2pgsql and as a database cache.

To decide how much cache to allocate, the rule of thumb is as follows: use the
size of the PBF file you are trying to import or about 75% of RAM, whatever is
smaller. Make sure there is enough RAM left for PostgreSQL. It needs at least
the amount of `shared_buffers` given in its configuration.

You may also set `--cache` to 0 to disable caching completely to save memory.
If you use a flat node store you should probably disable the cache, it will
usually not help in that situation.

In non-slim mode, i.e. when using the RAM middle, the `--cache` setting is
ignored. All data is stored in RAM and uses however much memory it needs.

### Bucket Index for Slim Mode

*Version >= 1.4.0*{: .version} This is only available from osm2pgsql version
1.4.0! It is enabled by default since 1.7.0.

Osm2pgsql can use an index for way node lookups in slim mode that needs a lot
less disk space than earlier versions did. For a planet the savings can be
about 200 GB! Because the index is so much smaller, imports are faster, too.
Lookup times are slightly slower, but this shouldn't be an issue for most
people.

*If you are not using slim mode and/or not doing updates of your database, this
does not apply to you.*

For backwards compatibility osm2pgsql will never update an existing database
to the new index. It will keep using the old index. So you do not have to do
anything when upgrading osm2pgsql.

If you want to use the new index, there are two ways of doing this: The "safe"
way for most users and the "do-it-yourself" way for expert users. Note that
once you switched to the new index, older versions of osm2pgsql will not work
correctly any more.

#### Update for Most Users

*Version >= 1.7.0*{: .version} In versions 1.4.0 to 1.6.0 the index was not
enabled by default. Add `--middle-way-node-index-id-shift=5` as command line
option for these versions. Do not use a number different than 5 unless you
know what you are doing.

If your database was created with an older version of osm2pgsql you might want
to start again from an empty database. Just do a reimport and osm2pgsql will
use the new space-saving index.

#### Update for Expert Users

This is only for users who are very familiar with osm2pgsql and PostgreSQL
operation. You can break your osm2pgsql database beyond repair if something
goes wrong here and you might not even notice.

You can create the index yourself by following these steps:

Drop the existing index. Replace `{prefix}` by the prefix you are using.
Usually this is `planet_osm`:

```sql
DROP INDEX {prefix}_ways_nodes_idx;
```

Create the `index_bucket` function needed for the index. Replace
`{way_node_index_id_shift}` by the number of bits you want the id to be
shifted. If you don't have a reason to use something else, use `5`:

```sql
CREATE FUNCTION {prefix}_index_bucket(int8[]) RETURNS int8[] AS $$
  SELECT ARRAY(SELECT DISTINCT unnest($1) >> {way_node_index_id_shift})
$$ LANGUAGE SQL IMMUTABLE;
```

Now you can create the new index. Again, replace `{prefix}` by the prefix
you are using:

```sql
CREATE INDEX {prefix}_ways_nodes_bucket_idx ON {prefix}_ways
  USING GIN ({prefix}_index_bucket(nodes))
  WITH (fastupdate = off);
```

If you want to create the index in a specific tablespace you can do this:

```sql
CREATE INDEX {prefix}_ways_nodes_bucket_idx ON {prefix}_ways
  USING GIN ({prefix}_index_bucket(nodes))
  WITH (fastupdate = off) TABLESPACE {tablespace};
```

#### Id Shift (for Experts)

When an OSM node is changing, the way node index is used to look up all ways
that use that particular node and therefore might have to be updated, too.
This index is quite large, because most nodes are in at least one way.

When creating a new database (when used in create mode with slim option),
osm2pgsql can create a "bucket index" using a configurable id shift for the
nodes in the way node index. This bucket index will create index entries not
for each node id, but for "buckets" of node ids. It does this by shifting the
node ids a few bits to the right. As a result there are far fewer entries
in the index, it becomes a lot smaller. This is especially true in our case,
because ways often contain consecutive nodes, so if node id `n` is in a way,
there is a good chance, that node id `n+1` is also in the way.

On the other hand, looking up an id will result in false positives, so the
database has to retrieve more ways than absolutely necessary, which leads to
the considerable slowdown.

You can set the shift with the command line option
`--middle-way-node-index-id-shift`. Values between about 3 and 6 might make
sense, from some tests it looks like 5 is a good value.

To completely disable the bucket index and create an index compatible with
earlier versions of osm2pgsql, use `--middle-way-node-index-id-shift=0`.

### Middle Command Line Options

{% include_relative options/middle.md %}

