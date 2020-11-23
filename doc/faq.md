---
layout: doc
title: Frequently Asked Questions (FAQ)
---

<section markdown="1">

## Upgrade

### What do I have to know about upgrading osm2pgsql to a newer version?

We are trying hard to make newer versions of osm2pgsql backwards compatible
with older versions. Usually, you just have to upgrade the osm2pgsql executable
and you are done. But there are cases where you have to wipe your database and
start from scratch. See the [release
notes](https://github.com/openstreetmap/osm2pgsql/releases){:.extlink} and the
[Upgrading appendix in the manual](/doc/manual.html#upgrading) for details.

</section>
<section markdown="1">

## Usage

### I want some tables to be in a specific database schema

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

### An index is not being built and there is no error message.

You are probably using a version of osm2pgsql before 1.3.0 which had a bug
where errors happening while creating an index or certain other database
operations were not reported but silently ignored. This is fixed in version
1.3.0.

You might be able to find information about the problem in the PostgreSQL
log, most likely you ran out of disk space.

You should upgrade osm2pgsql to a current version.

### My osm2pgsql is crashing without reporting any useful error message.

This is most likely because you are running out of memory. Due to the way
Linux system "overcommit" memory, osm2pgsql can not detect that it is running
out of memory, so it can't tell you what's going on.

Please read the [Notes on Memory Usage](/doc/manual.html#notes-on-memory-usage)
in the manual to get some ideas how to handle this.

### Osm2pgsql created table columns I can't access.

Osm2pgsql usually creates table columns in your database that are named after
the OSM tag used, for instance, the `name` tag might end up in a column called
`name`. Sometimes this leads to problems when the tags contains unusual
characters, for instance the tag `addr:city` contains the colon character.
Another problem are reserved names in the PostgreSQL database, for instance
`natural`.

These names are allowed in PostgreSQL, but they need to be quoted with double
quotes (`"""`). Osm2pgsql does this quoting, so it doesn't have any problem
with these. But not all software does this.

You can define in the config file which columns you want, and, if you are using
the flex output, decide on how exactly your columns should be named and used.
There you can, for instance, create a column named `addr_city` and fill it
with the value of the `addr:city` tag.

### I can't find the coastline data

In the pgsql output the `natural=coastline` tag is suppressed by default, even
if you import the `natural=*` key. The main mapnik map renders coastlines from
other sources so it does not need them. You can use the `--keep-coastlines`
parameter to change this behavior if you want coastlines in your database.

See the [Coastline Processing section in the
manual](/doc/manual.html#coastline-processing)

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
