---
title: Requirements for CODA
layout: coda
---

*See [How osm2pgsql Data Processing Works]({% link
contribute/how-osm2pgsql-processing-works.md %}) for some useful background
information.*

This document describes the requirements for a database replacing the
PostgreSQL-based middle in osm2pgsql with a new compact OSM data archive
(CODA). Its main goal is to reduce memory and disk requirements as well as
speed up processing of osm2pgsql imports and updates.

In the following we'll talk about a "database" in the sense that we have a
structured set of data, not in the sense that there is a database server. There
is no need for a server, because the database does not need to be accessible
over the network and there is at most a single writer active at any time.

## Use Cases

The main use case is to support updates of an osm2pgsql database. The CODA
contains all the data that's needed to keep the osm2pgsql output database
updated when OSM data changes.

A secondary use case is for a non-updateable database where the RAM middle can
not be used due to memory constraints.

Both use cases are currently supported by the "pgsql" middle which stores the
data in the PostgreSQL database in conjunction with the "flat node file". But
this approach comes with quite a lot of overhead due to the general purpose
database used. And the "flat node file" works reasonably efficiently for the
whole planet but doesn't work well for smaller extracts.

See the "Extras" chapter below for possible other use cases.

## The CODA

### The Object Store

The database must contain an "object store" which contains all the OSM objects
(nodes, ways, and relations) in their "OSM-native" form indexed by ID.

* Objects are addressed by their 64bit unsigned integer ID.
* For all objects all tags must be stored.
* For nodes, the location must be stored.
* For ways, the list of member nodes must be stored. It might also be possible
  to store the location of those nodes with the ways.
* For relations, the list of members with type, id, and role must be stored.
* For all object types, attributes (version, timestamp, changeset id, user id)
  must optionally be stored. Most osm2pgsql instances don't need that
  information so this must be optional and not incur any overhead if not
  needed.
* If the user id is stored for objects, a mapping from user id to user name
  must also be stored if requested by the user.

In general the object store contains all the same information that is in an OSM
file, it must be theoretically possible to re-create the contents of the OSM
file used to populate the database from the database's contents.

Note that it is not necessarily so that all data for a single object is
co-located in that object store. In typical cases we only need some of the
data:

* For each way or relation that is updated in stage 1b we need the full object
  data (tags, attributes, members) from the object store, because this is given
  to the Lua processing function.
* For some ways being imported or updated we need the node locations to build
  the geometry on request.
* For some relations being imported or updated we need the node list of the
  way members and the locations of directly or indirectly used nodes to build
  the geometry on request.

### Nodes

Storing attributes/tags from nodes is not required for updates. This is
different than for ways and relations, which need to be stored because changes
in nodes can trigger changes in ways etc. which are not in the change file
themselves. But changed nodes are always in the change files. We do need the
locations of the nodes, though.

Nevertheless it makes sense to store full information on nodes, possibly
optionally, and optionally only for tagged nodes, because this will later open
up new use cases: In the Lua config file, we could allow access to node
information from the ways or relations that reference them which would be
useful in some cases.

### Indexes

To support updates we'll need indexes for the following:

* Find all parent ways of a node
* Find all parent relations of a node
* Find all parent relations of a way

We should (optionally) add an index to find all parent relations of a relation.
This is currently not needed, but it might be useful in the future. (See:
[Road Map: Advanced OSM Object Processing]({% link about/road-map.md
%}#advanced-osm-object-processing).)

There are no indexes needed for access by geometry, by tags, or by any of the
attributes.

### Performance

Our goal is to create a database that can keep up with minutely changes from
OSM. This means updating the CODA as well as updating the main database with
the output tables must, on average, be done in less than a minute, preferably
much faster. Although discouraged, occasional longer runs are okay, for
instance to "vacuum" the object store or rebuild an index.

It is important that access to node locations is very fast, because we need
them to build over a billion way and relation geometries.

### Consistency Requirements

The database must be updateable. Only a single writer changes the database at
any time and where reads are done during the update process they are done in a
way that they are not affected by the writing. The database must support some
kind of locking mechanism to ensure this. Full ACID compliance is not required,
in fact that's one of the reasons why this database might be more efficient
than a real ACID compliant database.

Failed (incomplete) updates must keep the database in a usable condition and a
retry of the update must have the same effect as if the first update worked
correctly. In fact, replay must work in general, not just in case of failed
updates, because it is not always clear whether an update succeeded or not. So
it must always be possible to go arbitrarily far back and reapply updates.
After all updates have been applied the database must look the same as if the
updates have only been applied once.

We assume that we will always have control over all programs that access CODA,
this will mainly be osm2pgsql itself, maybe others in the future. Those
programs have to make sure that they lock access of the database against each
other (so that, for instance, a program started as a cronjob will not interfere
with another instance running) and while they are running they have to make
sure to not mix reading and writing CODA in a way that could affect
consistency.

## Extras

The following issues are not part of this project, but might be added in the
future. They are added here to inform architectural decisions.

### Populating an osm2pgsql Database from Middle

It could sometimes be useful to create an osm2pgsql output database not from an
OSM file but from the CODA. This is not possible yet in osm2pgsql.

To support that CODA must allow efficiently iterating over all nodes, ways, and
relations in ID order.

This would allow two additional use cases:

* Download and use of pre-created CODA files instead of OSM data files.

* Creating the CODA and the output database in two steps instead of a single
  step. While probably slower overall this could help in situations where
  ressources are extremly tight.

### Keeping Extracts up to date

A recurring problem is how to keep geographical extracts up to date. Osm2pgsql
already suppports a specific case where you keep all OSM data in the middle
tables and only write some data to the output tables using the Locator
feature. The CODA middle should support this operating mode.

But this mode is wasteful, it should be possible to import only objects inside
some bounding box into the middle tables or the CODA. To avoid most issues with
objects at the boundary of the area of interest, that bounding box should be
larger than the area of interest. All nodes in the bounding box are stored in
the middle and all ways that have at least one node in the bounding box. For
relations this is somewhat more complicated, details need to be determinded.

This issue is completely independent of the implementation of the middle, but
mentioned here so that we can make sure we are not missing something in the
implementation that could prevent us from implementing this feature in the
future.

### Sharing the CODA

Lets say you want to update several osm2pgsql output databases at the same
time. Maybe they contain different extracts, maybe they contain different
schemas, maybe they were created at different times. It could be useful to be
able to have a single CODA shared by all the instances of the osm2pgsql
database. This is somewhat related to the use case in the previous section.

### Access from PostgreSQL

The main drawback of the CODA compared to storing the middle data in the
PostgreSQL database is that the data can not be accessed from the database that
contains the output tables. This is not necessary in most cases, but it can
sometimes be useful and could reduce storage overhead in some cases. It could
be possible to make the CODA available to PostgreSQL though some kind of
foreign data wrapper.

Note that this would probably involve having full (or fuller) ACID compliance
while the database described in this document does not need full ACID
compliance. This is because there can be (read) accesses from PostgreSQL while
osm2pgsql is changing the database. A reasonable compromise could be to allow
access only when we know that the CODA is in a consistent state, i.e. when
osm2pgsql is not running or when osm2pgsql is running and it knows the CODA is
in a consistent state, for instance between processing nodes and ways. But
"random" accesses, for instance at rendering time, are not allowed.

### Reuse in other Contexts

Having an updateable database of OSM data is not only useful for osm2pgsql,
there are many other use cases. So if it turns out during the project that we
can implement this database (or parts of it) in a resusable way, for instance
as a standalone C++ library or an extension to the libosmium library, this will
be considered.

### Historical Data

Working with historical data is out of scope for this project, we only need to
keep the current OSM data in the database.

