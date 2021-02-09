---
layout: doc
title: Frequently Asked Questions (FAQ)
---

<section markdown="1">

## Usage

### What do I have to know about upgrading osm2pgsql to a newer version?

We are trying hard to make newer versions of osm2pgsql backwards compatible
with older versions. Usually, you just have to upgrade the osm2pgsql executable
and you are done. But there are cases where you have to wipe your database and
start from scratch. See the [release notes]({% link releases/index.md %}) and
the [Upgrading appendix in the manual](/doc/manual.html#upgrading) for details.

### Can I have my tables in a specific database schema?

This is supported starting from version 1.4.0.

* For tables created by the flex output use the `schema` option on the
  [table creation commands](/doc/manual.html#defining-a-table) in the Lua
  config file.
* For tables created by the pgsql output use `--output-pgsql-schema=SCHEMA`.
* For middle tables use `--middle-schema=SCHEMA`.

</section>
<section markdown="1">

## Problems

### Why is osm2pgsql so slow?

Osm2pgsql can take quite some time to import OSM data into a database, possibly
many hours or even days. There are many reasons for this:

* There is a lot of data. A full planet will create a database with hundreds
  of GBytes, this just needs time.
* Your hardware may be underpowered. You should use a fast SSD and have plenty
  of RAM, for a planet import 64 GB RAM are pretty much the minimum.
* You have to tune your PostgreSQL config *before* using osm2pgsql. The
  default settings for PostgreSQL on most systems are totally wrong for a
  large database. Don't forget to restart the database after tuning.
  See the [manual](/doc/manual.html#tuning-the-postgresql-server) for
  details.
* The command line options chosen can have a large impact on performance.

All that being said, on a reasonably modern machine with 64GB RAM and SSDs you
should be able to import a planet file in something like half a day.

### Why is an index not being built and there is no error message?

You are probably using a version of osm2pgsql before 1.3.0 which had a bug
where errors happening while creating an index or certain other database
operations were not reported but silently ignored. This is fixed in version
1.3.0.

You might be able to find information about the problem in the PostgreSQL
log, most likely you ran out of disk space.

You should upgrade osm2pgsql to a current version.

### Why is osm2pgsql crashing without reporting any useful error message?

This is most likely because you are running out of memory. Due to the way
Linux system "overcommit" memory, osm2pgsql can not detect that it is running
out of memory, so it can't tell you what's going on.

Please read the [Notes on Memory Usage](/doc/manual.html#notes-on-memory-usage)
in the manual to get some ideas how to handle this.

### Why can't I access a table column created by osm2pgsql?

Osm2pgsql usually creates table columns in your database that are named after
the OSM tag used, for instance, the `name` tag might end up in a column called
`name`. Sometimes this leads to problems when the tags contains unusual
characters, for instance the tag `addr:city` contains the colon character.
Another problem are reserved names in the PostgreSQL database, for instance
`natural`.

These names are allowed in PostgreSQL, but they need to be quoted with double
quotes (`"..."`). Osm2pgsql does this quoting, so it doesn't have any problem
with these. But not all software does this.

You can define in the config file which columns you want, and, if you are using
the flex output, decide on how exactly your columns should be named and used.
To avoid this problem, you can, for instance, create a column named `addr_city`
and fill it with the value of the `addr:city` tag.

### Where is the coastline data?

In the pgsql output the `natural=coastline` tag is suppressed by default, even
if you import the `natural=*` key. The main mapnik map renders coastlines from
other sources so it does not need them. You can use the `--keep-coastlines`
parameter to change this behavior if you want coastlines in your database.

See the [Coastline Processing section in the
manual](/doc/manual.html#coastline-processing)

### Why is this OSM object missing in my database?

There are many reasons why an OSM object might not end up in the database.
First make sure it is actually in the input data. For ways and relations make
sure the nodes or member objects they reference are in the input data. (You can
use [`osmium
check-refs`](https://docs.osmcode.org/osmium/latest/osmium-check-refs.html){:.extlink} for
this.)

If the data is there it can still mean it is invalid in some way. Osm2pgsql has
to build the geometry and if this fails, the object is silently ignored. This
most often happens for [multipolygon
relations](https://wiki.openstreetmap.org/wiki/Relation:multipolygon){:.extlink}
but can happen for other data, too.

There are several [quality assurance
tools](https://wiki.openstreetmap.org/wiki/Quality_assurance){:.extlink} out
there that can help you to diagnose issues like this. The [OSM Inspector
"Areas" view](https://tools.geofabrik.de/osmi/?view=areas){:.extlink} helps
specifically with finding multipolygon problems.

</section>
<section markdown="1">

## Error Messages

Here are some of the error messages osm2pgql will produce and what you do
if you get them.

### `bad_alloc` or `segmentation fault`

Most likely this means that you ran out of memory. But it can also mean there
is a bug in osm2pgsql. Check that you have enough memory, try with more. If the
problem persists and you believe you have enough memory for what you are doing,
[report it](https://github.com/openstreetmap/osm2pgsql/issues/new){:.extlink}.

Please read the [Notes on Memory Usage](/doc/manual.html#notes-on-memory-usage)
in the manual to get some ideas how to handle this.

### `No tables defined in Lua config. Nothing to do!`

You are using the flex output and the Lua config you have specified doesn't
define any output tables. You need to [define at least one output
table](/doc/manual.html#defining-a-table).

You'll also get this error if you are using a pgsql Lua transform file with
the flex output!

</section>
<section markdown="1">

## Features

### Can we have support for other databases?

Osm2pgsql is tied closely to the PostgreSQL database and uses many special
features of the PostgreSQL/PostGIS combination. Making sure osm2pgsql works
with all PostgreSQL/PostGIS versions and has acceptable performance is already
a big task. Adding support for other databases is not on our list of things to
do.

We will consider pull requests with changes that make use of osm2pgsql with
other databases easier (or possible) if the changes do not affect usability or
performance for PostgreSQL users and if the changes can be cleanly integrated
into the code. Because we don't have the time to test new versions of osm2pgsql
with other databases (or can't even do it because we don't have access to those
databases), we can not guarantee that things will not break in the future.

</section>

{% include heading-links.html %}
