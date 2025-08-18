---
layout: default
title: Road Map
---

# Road Map for osm2pgsql

This document is a road map for osm2pgsql development. It's not to be
understood as a definite "this is what we'll do" document, but as a rough
overview of the shared understanding of the maintainers about where we are and
what we are working towards in the next years.

If you are interested in more concrete features to expect or implement,
have a look at the [list of project ideas]({% link contribute/project-ideas.md
%}).

## What osm2pgsql is and what it isn't

osm2pgsql is a software that reads OpenStreetMap data in all common formats
and puts the data into a PostgreSQL/PostGIS database to be further processed.
osm2pgsql is not just a backend for rendering. It needs to be flexible enough
to support many kinds of application on top of the resulting database.

The import process needs to make it easy to apply common transformations
to OSM data. The most important example here is the creation of Simple
Feature geometries but other common patterns may emerge and need to be
supported. That said, osm2pgsql is not a general transformation library and will
stay away from tasks that can be solved by database operations just as easily.

osm2pgsql must give good results when used with minimal configuration. At the
same time it should remain flexible enough that power users can cover complex
use cases with a bit of additional configuration work. Hard-coded policy
decisions should be avoided if possible.

Updating databases is supported through diff files and replication processes.
In its standard operation mode, the user should be able to write a single
configuration file that transparently works for imports and updates in the
same way. Power users should be provided with the necessary information and
tools to create dedicated update processes and configurations.

## Towards osm2pgsql version 3

The following sections describe the major areas of interest that we have on
our road map for the medium to long-term future of osm2pgsql.

Next to these wider reaching goals, there is of course always maintenance:
responding to bug reports, keeping the code clean and making sure everything
runs with old and new versions of the libraries we use and on old and new
versions of operating systems.

### Moving away from Multiple Outputs

osm2pgsql used to provide some flexibility for the output tables through
different output implementations. With the introduction of the flex output,
separate C++ implementation of outputs are no longer necessary. Users can
easily implement arbitrary output layouts through its Lua configuration.

Version 2.0 has already removed most of the outputs. The *pqsql* output
has been deprecated and is now in maintenance mode. It will be removed in
version 3.0. Future extensions to the output model will only be implemented
in what is now called the *flex* output and will just be *the* output in
version 3.

### Object Store / Middle / Flat Node Store

To be able to resolve relations between objects (nodes in ways, members in
relations) and to update its database from OSM change files, osm2pgsql needs to
keep an object store of all OSM objects it has seen and their relationship with
each other. This is often called "middle" in osm2pgsql-speak. It comes in two
"flavours" depending on whether it supports updates or not.

The updatable middle uses the PostgreSQL database. We have already moved to
a more approachable data structure here, which makes the stored information
easily accessible for users. This comes at a price in terms of storage space
and some performance penalty. Given OSMs current rate of growth, the size
of the middle tables alone may become too large for average users to handle.
We are also running into performance problems due to large GIN indexes.

We need to look into more size efficient data structures for this middle
cache. This will very likely mean to move it out of the PostgreSQL database.
At the same time we would like to keep the new-found possibility for users
to access the data from inside the database. How these two goals can be consolidated,
is still a matter of discussion.

The flat node store, which stores coordinates of nodes, is also part of this
topic.

### Future of the Processing Pipeline

osm2pgsql started out with processing OSM data in fixed number of sequential
steps: Database tables are created, then data is imported, then clustered,
then indexes created. This view of an import process only works well under
the assumption that every OSM object can be processed independently from
each other. This assumption has never really held. OSM's topological data model
has inherent dependencies between nodes, ways and relations. osm2pgsql
has always gone to some length to hide this reality from the users: the
data import is internally split into two stages where first the actual input
is processed and then any objects that depend on the input.

With the growing complexities of OSM data, there are more and more external
dependencies. Hiking and cycling routes depend on information from the ways
they go along. The available amenities of a camping site can only be determined
by looking at the POIs inside the camping area.
[Two-stage processing](https://osm2pgsql.org/doc/manual.html#stages) and
the [generalization project](https://osm2pgsql.org/generalization/) tried
to address this need to process dependent data. They both have their uses
and limitations.

We'd like to come to a unified processing model that covers the use cases
of these two extensions but also includes internal processing steps like
the setup of the middle storage, clustering and index building. By viewing
these steps rather as building blocks with dependencies on each other, we
might be able to create a model that is easier to distribute over available
resources and parallelize.

The challenge here will be to make such a processing pipeline work with
updates in a way that is mostly transparent to the user. The model also
needs to be easily configurable by the user. In particular, it must remain
easy to understand for those users that just want to quickly load OSM data
into a database.


### Tile Expiry

osm2pgsql can generate a list of tiles that need to be expired due to updates
to the database. The code creating the expire lists is very outdated and
needs to be modernised. The expiry lists are also far from optimal and
often contain more expired tiles than necessary, especially for polygons.

We'd like to rethink how expiry works and modernize and optimise the code
along the way.
This needs a deep look into what users actually need and how we can best
support it. We should also think about whether we can do expiry calculations
based on output tables, not data input. This ties in with the generalization
work mentioned below, because -- in a way -- expire lists are also just
generalizations of geometries.


### Advanced OSM Object Processing

One of the goals of osm2pgsql is to give the user a generic toolbox for
commonly used operations on OSM objects. Right now this is mainly restricted
to processing of tags and creation of geometries for nodes, ways and areas.

Since version 1.9.0 we have explicit generalization support, providing some
additional advanced geometry processing. But there is still a long way to go.

We'd also like to extend support for relation types besides multipolygon,
boundary, and route relations. Ideally there should also be better mechanisms
to work with *any* relation type but it is unclear what this could look like
beyond writing them to the database as a GeometryCollection which is possible
since version 1.7.0.

This is an area where we need more input from users to see what their needs
are. And we need to do more research where OSM data handling can be generalized
and where domain-specific knowledge is needed.


### Generalization

For small zoom levels, geodata needs to be generalized. This is needed for
speed and to reduce the amount of data being moved around over the network. But
it is also needed to show maps that are usable and useful, and that look good.
We have started work on this with the [generalization
project](https://osm2pgsql.org/generalization/), but there is much more to do.

Generalization is implemented in several "strategies" that deal with certain
types of data and solve specialized use cases. Currently there are only a few
strategies implemented and we plan to add many more. For instance there are
existing strategies to generalize landcover data, but no strategies yet to do
generalizations of road networks.

Generalization strategies fall into several "families". Some strategies always
work on *all* data. Those are easier to implement but make updates more
expensive. Some strategies are tile-based, updates can be done tile-by-tile.
Missing is a general framework for implementing strategies with object-based
updates. For this osm2pgsql needs to keep track of all input objects that have
been used for some generalized object so that changes in those objects can be
reflected in the generalized object. Such a mechanism probably also has to
keep track of specific attributes of those objects so that new objects with
those attributes can be taken into account.

Currently generalization is still marked as experimental. It is used through
the `osm2pgsql-gen` program and only loosely integrated with the rest of
osm2pgsql. We want to get to a better integration but it is as yet unclear
how exactly this should look. This is also related to several other topics
mentioned in this road map.

