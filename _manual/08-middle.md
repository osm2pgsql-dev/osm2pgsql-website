---
chapter: 8
title: Middle
---

This chapter is incomplete.
{:.wip}

The middle keeps track of all OSM objects read by osm2pgsql and the
relationships between those objects. It knows, for instance, which ways are
used by which nodes, or which members a relation has. It also keeps track of
all node locations. It information is necessary to build way geometries from
way nodes and relation geometries from members and it is necessary when
updating data, because OSM change files only contain changes objects themselves
and not all the related objects needed for creating an objects geometry.

### Database Structure

The middle stores its data in the database in the following tables. The
`PREFIX` can be set with the `-p, --prefix` option, the default is
`planet_osm`. (Note that this option is also interpreted by the pgsql output!)

| Table        | Description   |
| ------------ | ------------- |
| PREFIX_nodes | OSM nodes (not used if the flat node store is used |
| PREFIX_ways  | OSM ways      |
| PREFIX_rels  | OSM relations |
{:.desc}

The names and structure of these tables, colloquially referred to as "slim
tables", are an **internal implemention detail** of osm2pgsql. While they do
not usually change between releases of osm2pgsql, be advised that if you rely
on the content or layout of these tables in your application, it is your
responsibility to check whether your assumptions are still true in a newer
version of osm2pgsql before updating. See [this
issue](https://github.com/openstreetmap/osm2pgsql/issues/230) for a discussion
of this topic.
{:.note}

### Flat Node Store

`--flat-nodes` specifies that instead of a table in PostgreSQL, a binary
file is used as a database of node locations. This should only be used on full
planet imports or very large extracts (e.g. Europe) but in those situations
offers significant space savings and speed increases, particularly on
mechanical drives. The file takes approximately 8 bytes * maximum node ID, or
more than 50 GiB, regardless of the size of the extract.

### Caching

`--cache` specifies how much memory in MB to allocate for caching information.
In `--slim` mode, this is just node positions while in non-slim mode it has to
store information about ways and relations too. The rule of thumb in slim mode
is as follows: use the size of the PBF file you are trying to import or about
75% of RAM, whatever is smaller. Make sure there is enough RAM left for
PostgreSQL. It needs at least the amount of `shared_buffers` given in its
configuration. You may also set `--cache` to 0 to disable node caching
completely. This makes only sense when a flat node file is given and there
is not enough RAM to fit most of the cache.

### Bucket Index for slim mode

*Version >= 1.4.0*{: .version} This is only available from osm2pgsql version
1.4.0!

The default is still to create the old index for now.
{: .note}

Osm2pgsql can use an index for way node lookups in slim mode that needs a lot
less disk space than earlier versions did. For a planet the savings can be
about 200 GB! Lookup times are slightly slower, but this shouldn't be an issue
for most people.

*If you are not using slim mode and/or not doing updates of your database, this
does not apply to you.*

For backwards compatibility osm2pgsql will never update an existing database
to the new index. It will keep using the old index. So you do not have to do
anything when upgrading osm2pgsql.

If you want to use the new index, there are two ways of doing this: The "safe"
way for most users and the "doit-it-yourself" way for expert users. Note that
once you switched to the new index, older versions of osm2pgsql will not work
correctly any more.

#### Update for most users

This does not work yet. Currently the default is still to create the old type
of index.
{: .note}

If your database was created with an older version of osm2pgsql you might want
to start again from an empty database. Just do a reimport and osm2pgsql will
use the new space-saving index.

#### Update for expert users

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

#### Id shift (for experts)

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
sense.

To completely disable the bucket index and create an index compatible with
earlier versions of osm2pgsql, use `--middle-way-node-index-id-shift=0`.
(This is currently still the default.)

### Middle Command Line Options

{% include_relative options/middle.md %}

