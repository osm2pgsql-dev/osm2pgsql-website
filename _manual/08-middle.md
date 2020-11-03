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


{% include_relative options/middle.md %}

