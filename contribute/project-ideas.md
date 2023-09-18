---
title: Project Ideas
---

# Project Ideas

We have many ideas for new features and capabilities for osm2pgsql. Here is a
list of some medium to large projects we want to do at some point. Each one
will take several days or weeks or even longer. It is unlikely that we will
have the time to work on many of these in the near future, so don't hold your
breath.

Note that the descriptions below are somewhat vague, that's because these are
ideas, not complete specifications. For most of the projects the coding part is
probably going to be smaller than the design, which has to make sure everything
fits well with other parts of osm2pgsql, is maintainable in the long term and
so on. (For more concrete projects see the
[issues](https://github.com/openstreetmap/osm2pgsql/issues)).

If you are a developer with some time on your hands and one of these ideas
seems interesting to you, by all means go ahead and give it a shot. Play around
a bit and think about how you would solve that problem. Before you invest a lot
of time or write a lot of code you should come talk to us. All these ideas are
interconnected with other projects and we want to help getting to a solution
that fits into osm2pgsql. If there isn't already a
[discussion](https://github.com/openstreetmap/osm2pgsql/discussions) about that
topic, start one.

If you are the boss of a company or other organization and need one of those
features, you can help getting it done by paying somebody. If you have
developers in your organization, you can let them work on it. Or you can
contract one of the osm2pgsql developers to do the work. If you don't have the
kind of money to support development of a complete feature but have some money,
[contact us]({% link support/index.md %}#commercial-support) and tell us what
you need. Sometimes we can get several people with similar goals together to
jointly fund something.

## Area Checks on Import

There are many cases where you need to know in which country (or state or
region or some kind of area) a feature is to process or style it properly. For
instance, highway shields look different in each country, so you might want to
style them differently. Or you want to do something different with name labels
depending on the language spoken in some area. For routing you might need
different default speed limits depending on country.

You can do this check in the database after running osm2pgsql, but it would be
nice (and more performant) to be able to do this on the fly on import. We'd
need some facility to define areas of interest, for instance from GeoJSON files
or from a database table. And then all imported objects need to be checked
against those areas and labelled accordingly in some way. This could also be
used to limit import to some area.

## Coastline Processing

Most maps need to differentiate between ocean and land areas or want to render
the coastline in some way. Currently coastline processing is done with the
separate program [OSMCoastline](https://osmcode.org/osmcoastline/){:.extlink} or
the data is simply downloaded from
[osmdata.openstreetmap.de](https://osmdata.openstreetmap.de/){:.extlink}. There
are good reasons for that solution, but it is a bit cumbersome. With the new
generalization framework we have in osm2pgsql a solution inside osm2pgsql might
be possible.

Any solution must be able to cope with the problem that the coastline is often
broken somewhere on the planet creating invalid data. That's why this is
somewhat tricky and not just a case of merging all ways tagged
`natural=coastline` and creating polygons from that.

## Generalization

There are many opportunities to improve generalization support in osm2pgsql for
specific data types. Most important are probably buildings, the road network,
and boundaries.

See also the [generalization project page]({% link generalization/index.md %}).

## Using Information from Associated OSM Objects

The classic osm2pgsql processing models is based on the idea that each OSM
object can be processed on its own. You look at each node, way, or relation
separately. You'll need the node locations for the ways and you'll need the
member geometries for the relation, but that was it. But that's not really
enough. For many things we need the tags of related (member or parent) objects.

Maybe you want to treat a node tagged `barrier=gate` differently depending on
the type of highway it is on. Or you need the tags from a bus stop together
with the tags of the bus route relation.

There is already the two-stage processing which allows you to do some of that,
but it is limited.

## Processing Stages and Data Access

With the recent addition of generalization support we have two kinds of
processing in osm2pgsql. The first happens while the input data is read and you
get the usual callbacks into your Lua code. The important characteristic of
this phase is that you only work on one OSM object at a time. (There is
two-stage processing which allows limited access to other objects, but it works
essentially on the same model.)

In the generalization phase the whole model is different: You have access to
all data (as long as it is in the database already, either because it is in the
middle tables or because it was put into specific tables in the first phase).
But in that phase you don't have access to those objects from Lua, you either
have to trigger SQL code or you can use the predefined generalization code.

There are, of course, reasons for this and the combination does work well, but
maybe this is not all it could be. Specifically we could allow some kind of
Lua processing in later phases where access to all objects is possible. This
would make some processing easier than today where you either need to use
two-stage processing for some use cases or you need to split processing into
Lua in the first phase and some extra SQL processing in a later phase.

## Processing Stages and Dependencies

Osm2pgsql processes incoming data in several stages, first nodes, then ways,
then relations. Processing happens in the middle and in the output, data is
stored in the database, indexes are built which are needed for later processing
steps, and so on.

These stages are "hard-coded" in osm2pgsql in the sense that there is code that
says, do this first, then do this other thing, then these two things at the
same time and so on. Some work could probably be done in parallel, but we'd
have to write explicit code to do that, making sure that every stage is
finished before some later stage is started that needs the results of the
earlier stage (for instance an index must have been built in the database). As
we do more and more complex processing this becomes more and more difficult to
handle.

We need to think about a design where the processing stages are made explicit
in the code and dependencies between stages are modelled in the code. Ideally
we can then let things run and whenever something can be done in parallel,
osm2pgsql would "magically" do that. In practice this will probably not work,
because we have external constrains, chiefly the database I/O bandwith and
available RAM to consider. Running things in parallel might actually slow them
down. But without making those stages explicit we can't even begin to manage
the complexity that we are working towards.

If we have something like this we can also think about having some kind of
function to resume imports that have been broken off at some point. For that
each stage would have to be idempotent and we have to store somewhere which
stages have been completed.

## Handling Changed and Deleted Objects

When processing updates, osm2pgsql will handle deleted objects by simply
deleting them from the database. A changed object is handled as if it was
deleted and a new object created after that. But users often want to do some
extra processing when an object is deleted or changed.

Currently this can be handled by adding database triggers that do something
else instead of the delete. But that is somewhat cumbersome and, for changed
objects, we have to fit the "delete" and the "insert" together again to find
out that we had a "change" originally, something we knew at the start of the
processing chain, but that information is lost once we are inside the database.

We might need some extra callbacks into the Lua code for this and/or change the
DELETE/COPY we are doing now into some kind of "UPSERT".

## Marking Objects as Changed

Sometimes it can be useful to mark certain OSM objects as changed so that
osm2pgsql behaves as if it has read that object from an OSM change file. This
can be used, for instance, if the Lua config changed in some specific way and
you want to re-process some OSM objects that you know will be affected. This
makes only sense in slim mode, of course.

To implement this, osm2pgsql basically would have to read that object from the
middle and pretend that it just got it from the input file.

## Non-PostgreSQL Middle

In osm2pgsql-speak the "middle" is the part of the code that stores OSM objects
for dependency management and updates. Currently there are two middle
implementation, the "ram" middle for the non-slim mode which doesn't support
updates and the "pgsql" middle for slim mode which stores the data in the
PostgreSQL database and which supports updates. There are many advantages to
having this data in the database and we'll always have that and support that.
But for many osm2pgsql use cases a full relational database isn't really needed
for this and it comes with quite a lot of overhead for processing and disk
space.

It would be great to have an additional middle implementation with some kind of
custom disk-based database, this could be based on something like RocksDB or
written from scratch exactly for our use case. Users could then choose whether
they want the more efficient one or the more flexible PostreSQL-based one.

Extra points for writing a foreign data wrapper for PostgreSQL that can access
the external database. That would allow us to combine the advantages of both
solutions.

## Keeping Extracts Up-to-date

Many people don't need OSM data from the whole planet in their database but
only a small extract, say the data for a city or a country. For one-time
imports this is fine, you create the extract with a tool like Osmium and import
it. But keeping the database up-to-date is more complex. There are some
services out there which offer OSM change files for extracts but they are
limited to a fixed list of extracts and usually don't offer minutely updates.

The alternative currently is to either filter the change files downloaded from
planet.osm.org before feeding them into osm2pgsql or to apply them all and then
filter the database afterwards. Both solutions are cumbersome and have their
problems. It would be great to have a better solution here. Ideally osm2pgsql
could just consume the diffs downloaded from planet.osm.org and do the right
thing.

