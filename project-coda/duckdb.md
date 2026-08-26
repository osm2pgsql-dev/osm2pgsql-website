---
title: DuckDB
layout: coda
---

The [DuckDB](https://duckdb.org/){:.extlink} single-file database has become
quite popular in the last years. Is it an option?

Let's do some experiments...

## Using the `spatial` Extension

DuckDB has an extension called `spatial` that comes with a `ST_ReadOsm()`
function which gives us access to an OSM PBF file as if it were a database
table. We can use a few simple SQL commands in DuckDB to copy the data into
real DuckDB tables.

This turns a 5 GiB OSM PBF file into a 17 GiB database. This database contains
all nodes, ways, and relations with their tags and member info. It does not
contain attributes (they are not supported by `ST_ReadOsm()`). And it doesn't
contain indexes for finding ways and relations from their members, because
DuckDB doesn't support indexes on array columns.

An import of the planet file stopped (or slowed down to something unnoticable)
after eating all the memory of the machine.

We can "simulate" the indexes we need by creating a lookup table from node ID
to a list of way IDs. I tried testing this with the database import mentioned
above and DuckDB went way into swap, until I had to break off the attempt.

The DuckDB manual mentiones issues with memory when using indexes. It doesn't
look like this is a good way to go.

[SQL script used to import the data]({% link project-coda/duckdb-import-spatial.sql %})

## Using the `osmium` Extension

There is another [DuckDB extension that can read OSM
data](https://github.com/jake-low/duckdb-osmium){:.extlink} which I have also
tried. It exposes the object attributes, but not way members, and nodes without
tags are not accessible. And it does some other processing that isn't suitable
for what we need.

[SQL script used to import the data]({% link project-coda/duckdb-import-osmium.sql %})

## Using the ohsome-planet Project

The [ohsome-planet](https://github.com/GIScience/ohsome-planet/) project
uses Parquet files to store OSM (history) data. The focus is quite different
from what we are doing here, but the Parquet files are easily converted to
DuckDB files.

Running ohsome-planet with a 4.3 GiB OSM (non-history) extract and then reading
the data into a DuckDB database, creates a 8.5 GiB file (about 2x). And a
planet file with 92 GiB can be turned into a 313 GiB DuckDB database (about
3.4x).

These are the commands used to read the Parquet files created by Ohsome and
import the data into DuckDB:

```
CREATE TABLE nodes     AS SELECT osm_id, tags, centroid.x AS x, centroid.y AS y
                          FROM read_parquet('ohsome-planet/contributions/node-*.parquet')
                          ORDER BY osm_id;
CREATE TABLE ways      AS SELECT osm_id, tags, refs
                          FROM read_parquet('ohsome-planet/contributions/way-*.parquet')
                          ORDER BY osm_id;
CREATE TABLE relations AS SELECT osm_id, tags, members
                          FROM read_parquet('ohsome-planet/contributions/relation-*.parquet')
                          ORDER BY osm_id;
```

This needs quite a lot of RAM (and Swap).

For a "general" database format the numbers are not bad, but they don't include
attributes and they don't include nodes without tags!

Copying out the data into Parquet files with ...

```
COPY (SELECT * FROM nodes)     TO 'nodes.parquet' (FORMAT parquet);
COPY (SELECT * FROM ways)      TO 'ways.parquet' (FORMAT parquet);
COPY (SELECT * FROM relations) TO 'relations.parquet' (FORMAT parquet);
```

... results in 9.6 GiB, 121 GiB, and 59 GiB files, respectively. This is
smaller than the DuckDB database, but the files are not updatable any more.

## Conclusion

The disk space needed doesn't make this approach very promising. And the huge
memory use for some operations is equally problematic.

