---
layout: doc
title: Frequently Asked Questions (FAQ)
---

## Upgrade

### What do I have to know about upgrading osm2pgsql to a newer version?

We are trying hard to make newer versions of osm2pgsql backwards compatible
with older versions. Usually, you just have to upgrade the osm2pgsql executable
and you are done. But there are cases where you have to wipe your database
and start from scratch. See the
[release notes](https://github.com/openstreetmap/osm2pgsql/releases) and the
[migration notes](https://github.com/openstreetmap/osm2pgsql/blob/master/docs/migrations.md)
for details.

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
  large database.

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

