---
layout: default
title: Road Map
---

# Road Map for Osm2pgsql

Current as of 2024-09-18.

This document is a kind of road map for osm2pgsql development. It's not to be
understood as a definite "this is what we'll do" document, but as a rough
overview of the shared understanding of the maintainers about where we are and
in what areas we see need for work. It is incomplete.

## Where We Are: A Stable Platform

First and foremost osm2pgsql must be a stable and reliable platform for its
many users who use it every day to maintain current maps. Backwards
compatibility is important and must be kept wherever possible. This makes
developing new features more difficult, but it gives the users a way forward,
using new features as they are needed without the need for a break-the-world
update.

This also means that often ongoing maintenance, bugfixing, attending to
issues, making sure everything keeps working with old and new library and
operating system versions etc. is more important than new features.

The development mostly is done on Linux and most users use osm2pgsql on Linux.
Osm2pgsql must work well on all current and some older versions of major Linux
distributions.

Because we currently have no Windows or macOS developers the support for these
operating systems is "best effort", we try to keep it working but can not
promise anything.

Only 64 bit systems are supported.

Osm2pgsql currently needs a C++17 compiler, switching to newer C++ versions
will be considered based on availability in the Linux distributions we want to
support.

Osm2pgsql must always support all officially supported versions of PostgreSQL
(currently 11 and above) and maybe more. Some optional features might only be
supported in newer PostgreSQL versions.

Osm2pgsql wants to be as resource-friendly as possible. It must always be
possible to use it with small data extracts on a hobbyists laptop. Processing
the full planet file and running minutely updates must be possible on a
reasonably modern machine (128GB RAM, SSD).

## Where We Want to Go

The following sections describe major topics or areas of work. They are roughly
ordered from the more important, simpler, more near-term to the less important,
more complex, more "out there" ideas. This does not imply an order in which
problems will be tackled (or even whether they will be tackled at all).

We also have a [list of project ideas]({% link contribute/project-ideas.md
%}) with more long-term projects.

Note that many of the following topics overlap. Some topics have related issues
which are listed below, but not all open concerns appear in Github issues.
Some major "big picture" issues are highlighted at the top of the [Github
issues page](https://github.com/osm2pgsql-dev/osm2pgsql/issues){:.extlink}.

### Ongoing Maintainance

There is always the ongoing maintainance. Making sure everything runs with
old and new versions of the libraries we use and on old and new versions of
operating systems.

### Code Cleanup and Modernization

Osm2pgsql started as a C program, later it was converted to C++03, then to
C++11, C++14, and C++17. Most of the code has been cleaned up over the years,
but there is still some old code in there that could do with some cleanup. And
there are still some places where code linting tools such as clang-tidy report
potential problems.

The goal is to have clean and modern code that's easy to understand and change.
This is especially important to make it easier for non-core developers to
contribute.

This cleanup work is mostly something that can be done "on the side" whenever
that particular piece of code is touched anyway.

The main place left which needs updating in this regard is the expire code.
Some of the code in the pgsql output also shows its C legacy, but because
that code is deprecated anyway and will be removed, cleaning it up is not a
priority.

### Documentation

In 2020 the documentation for osm2pgsql has moved to a new website at
osm2pgsql.org. Lots of examples have been put on the website, too. There is
still work to be done to complete the docs. This can be done "on the side"
whenever it makes sense. It would also be nice to amend the documentation
with some tutorials and how-to type documents.

### Configuration / Command Line

The command line options show the history of osm2pgsql. A lot of options
would look different if we'd do them today. With the switch to version 2 we
have cleaned up a lof of that and with the removal of the pgsql output in
version 3 we'll be able to clean up a lot more.

Where possible we should differentiate clearly between style configuration
(everything related to tags etc.) which belong in the config files and
operational configuration (cache sizes, file names, etc.) which belong on
the command line.

### Object Store / Middle / Flat Node Store

To be able to resolve relations between objects (nodes in ways, members in
relations) and to update its database from OSM change files, osm2pgsql needs to
keep an object store of all OSM objects it has seen and their relationship with
each other. This is often called "middle" in osm2pgsql-speak. It comes in two
"flavours" depending on whether it supports updates or not.

The updatable middle uses the PostgreSQL database. Due to its current
structure and API only some information is available, for instance it isn't
possible to find node members of relations.

In 1.9.0 we released a major update to the database middle in 1.11.0 this
became the default. The legacy database middle will be removed in 2.0.0.

In the future we might need some caching mechanism so that expensive database
operations can be avoided as much as possible if the same information is asked
for multiple times.

The flat node store is also part of this topic. We need to re-think the
structure of the middle, the integration of the flat node store and caching
mechanism in a unified way.

A lot of the other topics mentioned below rely on a flexible and performant
middle.

As a possible future step we might want to look into (optionally) removing the
need for PostgreSQL for the updatable object store. Specialized file-based
data storage could improve performance considerably and reduce disk consumption
at the same time.

Issues:

* [193](https://github.com/osm2pgsql-dev/osm2pgsql/issues/193)
* [1323](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1323)
* [1466](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1466)

### Future of the Outputs

The flex output has taken some great strides in the last years and has been
used in production environments for a long time. Some originally missing
features have been added and it is ready to replace the other outputs. Users
should all be able to switch to the flex output without missing any features
they had in any of the other outputs. The *multi* output was already removed in
version 1.5.0. The *gazetteer* output will be removed in version 2.0.0.0. Long
term we want to also remove the *pgsql* output, it is marked as deprecated in
2.0.0., but there is no timeline yet.

New features are only available in the flex output.

* [1130](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1130)

### Processing Flexibility and Performance

Osm2pgsql processes data in several steps: Database tables are created, then
data is imported, then clustered, then indexes created. Some of those steps are
already configurable, but there is a lot of hardcoded logic in here. Users have
repeatedly asked for more flexibility, for instance for index creation, which
is now much more flexible.

We need some way of making this more configurable without breaking backwards
compatibility and without making the common use case too complicated. How to
best do this is currently unclear. The direction we have been going in with
the Lua configuration points towards a possible solution: Move more of the
decisions about *what* needs to be done into Lua, keeping the *how* in C++.
Then most users can use higher level Lua functions that hide some of the
complexity, but power users can still access lower-level functionality to
solve their specific needs.

Another issue which probably fits in here are performance aspects of the
processing steps and possible performance improvements to be gained here
for instance by caching.

Issues:

* [193](https://github.com/osm2pgsql-dev/osm2pgsql/issues/193)
* [799](https://github.com/osm2pgsql-dev/osm2pgsql/issues/799)
* [1046](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1046)
* [1248](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1248)
* [1751](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1751)

### Tile Expiry

Osm2pgsql can generate a list of tiles that need to be expired due to updates
to the database. It is memory intensive and the performance could probably
be improved.

This needs a deep look into what users actually need and how we can best
support it. We should also think about whether we can do expiry calculations
based on output tables, not data input. This ties in with the generalization
work mentioned below, because -- in a way -- expire lists are also just
generalizations of geometries.

Issues:

* [709](https://github.com/osm2pgsql-dev/osm2pgsql/issues/709)
* [776](https://github.com/osm2pgsql-dev/osm2pgsql/issues/776)
* [1662](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1662)

### Debugging and Testing Support for Style Writers

The flex output introduces a lot of flexibility and we should find ways of
aiding the style writers with testing and debugging their Lua config files.
The new BDD testing framework used points into an interesting direction here.

Issues:

* [1130](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1130)

### PostgreSQL and PostGIS Features

Since osm2pgsql was first developed the capabilities of PostgreSQL and PostGIS
have grown tremendously and we haven't always kept up to be able to take
advantage of new features like JSON(B) columns or GENERATED columns or new
index types. In some cases our understanding of what the database is doing
has improved and changes could introduce performance gains.

Issues:

* [37](https://github.com/osm2pgsql-dev/osm2pgsql/issues/37)
* [1085](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1085)

### Better Relation Support

Currently osm2pgsql only supports multipolygon, boundary, and route relations
in any meaningful way. Other relation types such as turn restrictions and
destination signs should be supported explicitly.

Ideally there should also be better mechanisms to work with *any* relation
type but it is unclear what this could look like beyond writing them to the
database as a GeometryCollection which is possible in version 1.7.0.

This is an area where we need more input from users to see what their needs
are.

### Advanced Geometry Options and Generalization

One area where osm2pgsql is lacking in functionality is advanced geometry
handling. Historically all it did was creating point geometries from nodes and
linestring or polygon geometries from ways and relations. With version 1.7.0
and especially version 1.9.0 with explicit generalization support this has
improved a lot, but there is still some way to go.

This is explored in the [generalization project]({% link
generalization/index.md %}).

Issues:

* [1663](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1663)
* [1764](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1764)

## Release Management

We do releases "whenever the time is right", lately this has been about
twice per year. Plus smaller bug fix releases in between.

Sometime in 2024 we plan to release a 2.0.0 that will remove some deprecated
features.

