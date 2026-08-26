---
title: Imposm3
layout: coda
---

As part of finding out what the best format for a new middle should look like
we want to look at what other people have been doing to store OSM data. We'll
look here at [Imposm3](https://imposm.org/docs/imposm3/latest/){:.extlink}
which basically has the same mission as osm2pgsql, importing OSM data into a
PostGIS database for rendering an other uses. For several years it was a strong
competition of osm2pgsql but it is only maintained on a minimal level now, not
getting any new development.

## Architecture

Imposm3 stores all "middle" data, it calls it "cache", on disk using several
[LevelDB](https://github.com/google/leveldb){:.extlink} key/value databases.

The cache is generated in a first step, before any data is imported into the
database. It takes only about 45 minutes to create the cache from a planet
file, it needs about 145 GiB, that's about 1.6x the size of the planet file.

No OSM object attributes (versions, changeset id, timestamp, user name/id)
are ever stored.

There are 7 LevelDB databases, 4 of them contain the data:

* `nodes`, `ways`, `relations` each store the respective OSM objects. Nodes
  and relations are only stored when they have tags, ways are always stored
  (because they are possibly needed as relation members, even without tags).
* `coords` store the coordinates of all nodes.

And 3 others LevelDB files contain indexes for finding parent objects. While
the database files are always there, they are only filled if the `-diff` option
is used:

* `coords_index`: Lookup from node id to way id.
* `coords_rel_index`: Lookup from node id to relation id.
* `ways_index`: Lookup from way id to relation id.

Note that the databases named `coord_*_index` do not store coordinates but
node ids!

Entries are only made in the index files if they are needed. For instance
only if a way is added to the output tables, are the nodes of that way added
to the `coords_index`. That is only possible, because imposm3 knows about what
is added to the output table. With osm2pgsql this is not possible in general,
because of the free-form Lua config.

## LevelDB

[LevelDB](https://github.com/google/leveldb){:.extlink} is a simple key-value
store. In this case keys are always (signed) 64bit integers. Values are
automatically compressed using the Snappy library. It supports only few
operations (get, set, delete, iterating over entries in key order) and only a
single writer, but those are the operations needed for our use case. [Internal
storage](https://github.com/google/leveldb/blob/main/doc/index.md){:.extlink}
seems to be quite efficient.

With imposm3 objects are stored low-level using Protobuf encoding (not to be
confused with the OSM PBF files which also use Protobuf encoding, but a
different one).

For the `coords` database and the indexes, entries are grouped in "bunches"
containing 32 entries which are delta- and varint-encoded. Imposm3 uses a
LRU cache to speed up access to the `coords` database.

In some places Imposm3 uses different code for the first import than for
updates. Filling the cache from scratch using ordered data can be done more
efficiently that way.

It is unclear exactly how LevelDB does the Snappy compression. Running Snappy
compression on individual entries produced negligeable compression ratios. The
data from running Imposm3 with and without the Snappy compression enabled
suggest that there is a 50% compression ratio, so it looks like the compression
must be done on larger pieces of data then only the entries. [This
article](https://omkarbdesai.medium.com/an-analysis-of-running-different-configurations-of-leveldb-655b13e2e79a){:.extlink}
claims it is done in 4 kB blocks, which sounds reasonable.

## Coordinate Storage

Needs 60 GiB for the planet which is considerably less than the 105 GiB
currently needed for the osm2pgsql flat node store. Its about 65% the size of
the 92 GiB planet file. On average each node location needs 5.78 bytes.

Reading the 4.3 GiB germany file creates a coordinate storage of 2.6GB, so
about 165% of the input file size. On average each node location needs 6.46
bytes. It is to be expected that the storage is less efficient for extracts due
to the fixed blocks of 32 nodes.

In any case the storage needed is less than the 8 bytes a location usually
needs.

## Tag Storage

Imposm3 usually only stores the tags in the cache that are actually needed.
It can do this, because it knows from it config file which tags those are.
(This is different from osm2pgsql with its Lua config file which allows more
complex tag matching, for instance using regular expressions). This can save
quite a bit of storage.

Tags are stored as an array of strings with alternating keys and values. Common
tags (key-value combinations like `building=yes`) and common keys with variable
values (like `name`) are replaced by special unicode characters. The lists are
hard-coded into [the
software](https://github.com/omniscale/imposm3/blob/master/cache/binary/tags.go){:.extlink}.
The lists were added to the source in 2013 and never changed after that.

## Lessons Learned

The Imposm3 cache is very well thought-through and implemented. It takes
advantage of many optimizations, some similar to what OSM PBF does, some
different.

* The Imposm3 cache works well with planet sized datasets and also with small
  extracts, something we have been struggling with in osm2pgsql due to the
  flat node file only working well for large extracts or the full planet.
  The node location store and index files are not as efficient for small
  extracts as for the planet due to the blocks.
* We should think about optionally allowing users to configure which tags are
  stored in the middle. It is not so easy to do this as in Imposm3 because
  users would need to explicitly list the tags or keys, but for some use cases
  this could significantly reduce the size of the middle database.
* Imposm3 cleverly only adds entries to the cache indexes, if the objects were
  added to the output tables. Depending on the configuration this can save
  quite a bit of space. Unfortunately that only works because of the limited
  configuration options in Imposm3, it does not work in osm2pgsql which uses
  Lua as a config language which can implement much more complex logic. There
  is also a problem in the implementation
  (https://github.com/omniscale/imposm3/issues/310){:.extlink}. Nevertheless we
  should keep this in mind, maybe this is something that can be used in very
  ressource-constrained environments with manual configuration?
* Storing common keys or key-value combinations in a compressed form can save
  quite a lot of disk space, see [tags]({% link project-coda/tags.md %}) for
  more experiments with that.

## Appendix: Database Sizes

The Imposm3 documentations says that the cache needs 2-3 times the size of the
PBF file. That number seems conservative.

I assembled some numbers for cache sizes [in this spreadsheet (PDF)]({% link
project-coda/imposm3-cache-size.pdf %}) (Source: [imposm3-cache-size.ods]({%
link project-coda/imposm3-cache-size.ods %})).

Size cache for planet file:

        with all tags:

         60G coords
         22G coords_index
         28M coords_rel_index
         12G nodes
        2.1G relations
         50G ways
        195M ways_index
        ====
        145G total (~ 1.6x osm.pbf)

        with all tags and full indexes:

         60G coords
         26G coords_index
        187M coords_rel_index
         12G nodes
          2G relations
         50G ways
        596M ways_index
        ====
        149G total (~ 1.6x osm.pbf)

