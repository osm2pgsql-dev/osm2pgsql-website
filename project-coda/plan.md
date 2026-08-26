---
title: Implementation Plan
layout: coda
---

Here is the plan for the CODA development:

## Architecture

### Metadata

All data is stored in a single directory that will be configurable on the
command line. This directory contains a JSON file which contains the meta
data for this data store, such as the CODA version (so we can change details
if the format later). All the other data is contained in file in the same
directory which are either named in the JSON file or use fixed names.

### Key-Value-Store

We base everything on a key-value store. Imposm3 shows that this is possible
and doesn't create huge databases if used properly. Implementing all the
low-level stuff ourselves adds quite a bit of complexity as can be seen in
the Overpass code.

There are [many key-value
stores](https://en.wikipedia.org/wiki/Ordered_key%E2%80%93value_store) around.
We'll test LevelDB, RocksDB and LMDB for which C/C++ libraries are widely
available and supported by large organizations. Others either don't have the
features we need or are less well supported.

### Storage in Blocks

Per entry overhead of key-value stores is low but not zero. And lots of data in
OSM compresses really well with delta- and varint-encoding. To make this
available we need to store data in blocks. Implementation should use a block
size defined at compile-time, we can determine the best block size with some
benchmark after everything is in place.

Block-based storage is used for node locations and for indexes. Objects with
their tags are stored directly in the key-value-store using their Id as key.
For ways and relations their members are also stored there. For nodes without
tags only the locations are stored unless the user chooses to store attributes.

Optional attributes are stored with their objects. A different form of storage
might be more efficient, but most users don't need them anyway, so we don't
need to spend too much time on optimizing this use case. We might change this
later if needed.

### Tag Storage

Implementation of Tag Storage based on a static combined key/tag dictionary
with additional of-the-shelf compression.

## Where does the Code go?

There are several options on where the code can go:

1. Full implementation inside the osm2pgsql application: This is simple but the
   code is not reusable elsewhere. Initial implementation might be somewhat
   slower, because it has to be integrated into osm2pgsql. Code can be written
   for exactly the needs of osm2pgsql.
2. Implementation as a new library: Makes the code reusable in other contexts,
   if it is written in a reasonably generic way. Introduces some overhead for
   the new library for testing setup, packaging, its own release cycles and so
   on.
3. Implementation inside libosmium: Libosmium is already used in osm2pgsql and
   other tools that might want to add support for CODA databases. It is used
   and packaged widely. Libosmium is a C++ header only library, adding optional
   dependencies for a new part of the library isn't a problem, any code that
   doesn't use CODA is not affected.

We have decided to go with option 3, the implementation in libosmium. This has
the added advantage that the widely used osmium tool application can easily be
extended to support low-level CODA functionality (such as import, querying,
dumping of data) that we otherwise would have to implement in osm2pgsql for
debugging and database maintainance.

## Implementation Plan

Next steps for the implementation are:

* Implement a prototype of the library functionality in a libosmium branch
  including some unit tests. The code should be written in a way that it can
  be compiled using any of the key-value-stores mentioned above (the
  choice has to be taken at compile time, not at run time.) This way we
  can test/benchmark the results with the different key-value-stores
  and decide later which one to use.
* Implement a prototypical extension to the "osmium" command line tool in a
  branch that supports various CODA database task: Import and update of a
  CODA database from OSM (change) files, database queries of single OSM
  objects and the other various lookups we need (find all ways using a
  given node etc.), dump of a complete database to an OSM file.
* Write some code that mimics the query behaviour of osm2pgsql on the
  CODA database. This means we need to update the database from a change
  file and query any data affected by that change.
* Use the above code to test/benchmark the database with the same access
  pattern that osm2pgsql has. Tweak code options (such as tag dictionary size,
  compression algorithms used, block sizes, etc.) to get the best results for
  our use case.
* Check behaviour of the CODA database when updated with OSM change data
  of several months or even years to check database bloat. Implement
  "cleanup" functionality if needed.
* Decide which key-value-store to use.
* Add the code to use the CODA database to osm2pgsql in a branch. At this point
  most of the needed code has already been written, so it "only" needs to be
  integrated into osm2pgsql. Add tests to osm2pgsql.
* Add any missing tests and documentation, merge the branches in libosmium,
  osmium-tool and osm2pgsql in that order. Create releases for everything.

