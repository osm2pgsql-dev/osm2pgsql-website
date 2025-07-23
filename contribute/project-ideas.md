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
[issues](https://github.com/osm2pgsql-dev/osm2pgsql/issues){:.extlink}).

If you are a developer with some time on your hands and one of these ideas
seems interesting to you, by all means go ahead and give it a shot. Play around
a bit and think about how you would solve that problem. Before you invest a lot
of time or write a lot of code you should come talk to us. All these ideas are
interconnected with other projects and we want to help getting to a solution
that fits into osm2pgsql. You find a link to a discussion page for the project
below each description.

If you are the boss of a company or other organization and need one of those
features, you can help getting it done by paying somebody. If you have
developers in your organization, you can let them work on it. Or you can
contract one of the osm2pgsql developers to do the work. If you don't have the
kind of money to support development of a complete feature but have some money,
[contact us]({% link support/index.md %}#commercial-support) and tell us what
you need. Sometimes we can get several people with similar goals together to
jointly fund something.

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
implementations, the "ram" middle for the non-slim mode which doesn't support
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

## Improving Efficiency of Flat-Node Store

The flat-node store is part of the 'middle' storage and stores locations for
all OSM nodes. It's very simple array structure makes it easy to use and very fast.
It needs nearly 100GB storage, though, no matter if you are importing a
planet or just a small extract. We need a data structure that better
compresses the data and works well for full planets and extracts alike.

One possible venue to explore here is to find a more efficient encoding for
locations, for example through [interleaving encoding](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1466){:.extlink}.

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

[Discussion](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1248){:.extlink}

## Resuming imports/updates

Imports with osm2pgsql can take quite some time and if something breaks you
have to start from scratch. Some kind of "resume" feature is requested often
and we should look into what's needed for that.

We'd have to define checkpoints and make sure that all data is written to disk
at that point. Then on restart osm2pgsql has to detect that it failed and
resume at the correct point. In
[some situations](https://github.com/osm2pgsql-dev/osm2pgsql/issues/799){:.extlink}, the
user might also want to start osm2pgsql processing at a well defined point.

[Discussion](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1755){:.extlink}


## Tile Expiry

Osm2pgsql can generate a list of tiles that need to be expired due to updates
to the database. It is memory intensive and tends to create larger tile expiry
lists than necessary.

Polygon expiry is the most obvious target for improvements. We should expire
only tiles directly affected instead of the whole bounding box of the polygon.
Also on the wish list is an expiry that only takes the areas that have changed
into account instead of the whole polygon.

There are other parameters to expiry which we might want to give the user
an influence over. This needs a deep look into what users actually need and
how we can best support it.

[Discussion](https://github.com/osm2pgsql-dev/osm2pgsql/issues/1662){:.extlink}


## Debugging and Testing Support for Style Writers

The flex output introduces a lot of flexibility and we should find ways of
aiding the style writers with testing and debugging their Lua config files.

The new BDD testing framework might serve as a base for such a test tool.
It needs to be reviewed and the exising BDD commands cleaned up. Then we
need some scaffolding that allows the user to invoke the tests and some
user documentation on how to test user laud scripts.
