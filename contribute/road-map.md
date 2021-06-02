---
layout: default
title: Road Map
---

# Road Map for Osm2pgsql

Current as of 2021-04-30.

This document is a kind of road map for osm2pgsql development. It's not to be
understood as a definite "this is what we'll do" document, but as a rough
overview of the shared understanding of the maintainers about where we are and
in what areas we see need for work. It is incomplete.

## Where we Are: A Stable Platform

First and foremost osm2pgsql must be a stable and reliable platform for its
many users who use it every day to maintain current maps. Backwards
compatibility is important and must be kept whereever possible. This makes
developing new features more difficult, but it gives the users a way forward,
using new features as they are needed without the need for a break-the-world
update.

This also means that often ongoing maintainance, bugfixing, attending to
issues, making sure everything keeps working with old and new library and
operating system versions etc. is more important than new features.

The development mostly is done on Linux and most users use osm2pgsql on Linux.
Osm2pgsql must work well on all current and some older versions of major Linux
distributions.

Because we currently have no Windows or macOS developers the support for these
operating systems is "best effort", we try to keep it working but can not
promise anything.

Only 64 bit systems are supported.

Osm2pgsql currently needs a C++14 compiler, switching to newer C++ versions
will be considered based on availability in the Linux distributions we want to
support.

Osm2pgsql must always support all officially supported versions of PostgreSQL
(currently 9.6 and above) and maybe more. Some optional features might only be
supported in newer PostgreSQL versions.

Osm2pgsql wants to be as resource-friendly as possible. It must always be
possible to use it with small data extracts on a hobbyists laptop. Processing
the full planet file and running minutely updates must be possible on a
reasonably modern machine (64GB RAM, SSD).

## Where we Want to Go

The following sections describe major topics or areas of work. They are roughly
ordered from the more important, simpler, more near-term to the less important,
more complex, more "out there" ideas. This does not imply an order in which
problems will be tackled (or even whether they will be tackled at all).

Note that many of the following topics overlap. Some topics have related issues
which are listed below, but not all open concerns appear in Github issues.

### Ongoing Maintainance

There is always the ongoing maintainance.

Issues:

* [775](https://github.com/openstreetmap/osm2pgsql/issues/775)
* [965](https://github.com/openstreetmap/osm2pgsql/issues/965)
* [1010](https://github.com/openstreetmap/osm2pgsql/issues/1010)
* [1028](https://github.com/openstreetmap/osm2pgsql/issues/1028)

### Code Cleanup and Modernization

Osm2pgsql started as a C program, later it was converted to C++03, then to
C++11 and C++14. There is still old, often overly complex code in there that
could do with some cleanup. And there are still lots of places where code
linting tools such as clang-tidy report potential problems.

The goal is to have clean and modern code that's easy to understand and change.
This is especially important to make it easier for non-core developers to
contribute.

This cleanup work is mostly something that can be done "on the side" whenever
that particular piece of code is touched anyway.

### Documentation

The documentation for osm2pgsql has recently moved to a new website at
osm2pgsql.org. Lots of examples have been put on the website, too. There is
still work to be done to complete the docs. This can be done "on the side"
whenever it makes sense.

### Configuration / Command Line

Currently a lot of osm2pgsql options are only available through the command
line and most likely there will be more things we want configurable in the
future. We'll need to think about a more consistent story what options are
available where, how they interact and how to configure things that go beyond
the option=value paradigm.

Where possible we should differentiate clearly between style configuration
(everything related to tags etc.) and operational configuration (cache sizes,
file names, etc.)

Issues:

* [142](https://github.com/openstreetmap/osm2pgsql/issues/142)
* [272](https://github.com/openstreetmap/osm2pgsql/issues/272)

### Progress Output and Logging

While running osm2pgsql produces a lot of output telling the user what's going
on. But the output is sometimes inconsistent, sometimes osm2pgsql goes for a
long time without any output (especially when building indexes). With the
better logging code in 1.4.0 the situation is now much improved, but there
are still places where it can be done better.

Issues:

* [207](https://github.com/openstreetmap/osm2pgsql/issues/207)

### Object Store / Middle / Flat Node Store

To be able to resolve relations between objects (nodes in ways, members in
relations) and to update its database from OSM change files, osm2pgsql needs to
keep an object store of all OSM objects it has seen and their relationship with
each other. This is often called "middle" in osm2pgsql-speak. It comes in two
"flavours" depending on whether it supports updates or not.

The updateable middle uses the PostgreSQL database. Due to its current
structure and API only some information is available, for instance it isn't
possible to find node members of relations. Storing of OSM object attributes
(such as user id and timestamps) as pseudo-tags should be cleaned up to fix
corner-case problems. We can probably get some performance gains here by using
modern PostgreSQL features like JSONB columns.

Upgrading the data structure of the middle is especially difficult because of
the need to keep existing setups running without the need for a complete
reimport.

We also needs some caching mechanism so that expensive database operations can
be avoided as much as possible if the same information is asked for multiple
times.

The flat node store is also part of this topic. We need to re-think the
structure of the middle, the integration of the flat node store and caching
mechanism in a unified way.

A lot of the other topics mentioned below rely on a flexible and performant
middle.

As a first step in this we are cleaning up the code that's calling the middle,
the middle API, and existing middle code. And we are trying out some new middle
implementations.

As a possible future step we might want to look into (optionally) removing the
need for PostgreSQL for the updateable object store. Specialized file-based
data storage could improve performance considerably and reduce disk comsumption
at the same time.

Issues:

* [22](https://github.com/openstreetmap/osm2pgsql/issues/22)
* [193](https://github.com/openstreetmap/osm2pgsql/issues/193)
* [692](https://github.com/openstreetmap/osm2pgsql/issues/692)
* [1086](https://github.com/openstreetmap/osm2pgsql/issues/1086)
* [1170](https://github.com/openstreetmap/osm2pgsql/issues/1170)

### Future of the Outputs

There are some more or less obvious gaps in what the flex output can do
(`get_bbox` missing for relations, tables with multiple geometry columns,
two-stage processing of nodes and relations, more Lua helper functions to help
style writers, ...). This need some work.

Long term the flex output should replace all other outputs. Users should
all be able to switch to the flex output without missing any features they
had in any of the other outputs. Whether we'll actually remove the *pgsql*
and *gazetteer* outputs is not decided yet. The *multi* output was already
removed in version 1.5.0.

Some new features might only be available in the flex output.

* [1086](https://github.com/openstreetmap/osm2pgsql/issues/1086)
* [1130](https://github.com/openstreetmap/osm2pgsql/issues/1130)
* [1164](https://github.com/openstreetmap/osm2pgsql/issues/1164)

### Processing Flexibility and Performance

osm2pgsql processes data in several steps: Database tables are created, then
data is imported, then clustered, then indexes created. Some of those steps are
already configurable, but there is a lot of hardcoded logic in here. Users have
repeatedly asked for more flexibility, for instance doing index creation
separately, possibly with other index types etc.

We need some way of making this more configurable without breaking backwards
compatibility and without making the common use case too complicated. How to
best do this is currently unclear.

Another issue which probably fits in here are performance aspects of the
processing steps and possible performance improvements to be gained here
for instance by caching.

Issues:

* [27](https://github.com/openstreetmap/osm2pgsql/issues/27)
* [189](https://github.com/openstreetmap/osm2pgsql/issues/189)
* [193](https://github.com/openstreetmap/osm2pgsql/issues/193)
* [423](https://github.com/openstreetmap/osm2pgsql/issues/423)
* [799](https://github.com/openstreetmap/osm2pgsql/issues/799)
* [1046](https://github.com/openstreetmap/osm2pgsql/issues/1046)
* [1164](https://github.com/openstreetmap/osm2pgsql/issues/1164)
* [1248](https://github.com/openstreetmap/osm2pgsql/issues/1248)

### Tile Expiry

Osm2pgsql can generate a list of tiles that need to be expired due to updates
to the database. It is memory intensive and the performance could probably
improved.

This needs a deep look into what users actually need (the OSMF tile servers
don't even use this but have a different way of calculating expired tiles)
and how we can best support it. We should also think about whether we can do
expiry calculations based on output tables, not data input.

Issues:

* [38](https://github.com/openstreetmap/osm2pgsql/issues/38)
* [461](https://github.com/openstreetmap/osm2pgsql/issues/461)
* [709](https://github.com/openstreetmap/osm2pgsql/issues/709)
* [776](https://github.com/openstreetmap/osm2pgsql/issues/776)

### Debugging and Testing Support for Style Writers

The flex output introduces a lot of flexibility and we should find ways of
aiding the style writers with testing and debugging their Lua config files.

Issues:

* [1130](https://github.com/openstreetmap/osm2pgsql/issues/1130)

### PostgreSQL and PostGIS Features

Since osm2pgsql was first developed the capabilities of PostgreSQL and PostGIS
have grown tremendously and we haven't always kept up to be able to take
advantage of new features like JSON(B) columns or GENERATED columns or new
index types. In some cases our understanding of what the database is doing
has improved and changes could introduce performance gains.

Currently osm2pgsql opens a lot more database connections and keeps them open
longer than probably needed. There is some room for improvement there.

Issues:

* [37](https://github.com/openstreetmap/osm2pgsql/issues/37)
* [796](https://github.com/openstreetmap/osm2pgsql/issues/796)
* [1085](https://github.com/openstreetmap/osm2pgsql/issues/1085)

### Better Relation Support

Currently osm2pgsql only supports multipolygon, boundary, and route relations
in any meaningful way. Other relation types such as turn restrictions and
destination signs should be supported explicitly.

Ideally there should also be better mechanisms to work with *any* relation
type but it is unclear what this could look like beyond writing them to the
database as a GeometryCollection.

### Advanced Geometry Options and Generalization

One area where osm2pgsql is sorely lacking in functionality is advanced
geometry handling. Basically all it does is creating point geometries from
nodes and linestring or polygon geometries from ways and relations. For more
advanced maps we need more options for geometric generalizations (such as
line simplifications or collapsing polygons into their centroid).

Medium term we can find better ways of giving users access to PostGIS
capabilities. Long term we can also think about doing more geometry processing
in osm2pgsql itself.

Issues:

* [984](https://github.com/openstreetmap/osm2pgsql/issues/984)

