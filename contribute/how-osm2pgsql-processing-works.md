---
title: How osm2pgsql Data Processing Works
---

# How osm2pgsql Data Processing Works

Osm2pgsql reads OSM files and imports the data into a PostgreSQL/PostGIS
database. For normal OSM files this is pretty straightforward, but when updates
are involved this becomes more complicated. This document describes how the
osm2pgsql processing works internally. It is meant for osm2pgsql developers and
power users. You must have a good knowledge of the OSM data format to
understand this document.

## Definitions

OSM files contain a sequence of *OSM objects*. There are three different OSM
object types: *nodes*, *ways*, and *relations*. They must be in the input file
in this order. Osm2pgsql will complain if the object types are not in this
order. All OSM objects have an *id*, objects must be ordered by id in the input
file.

OSM objects can have additional attributes (*version*, *timestamp*,
*changeset*, *uid*, and *user*) which can optionally be stored by osm2pgsql but
they are not used internally for anything.

All OSM objects also have zero or more *tags*.

OSM nodes have a *location* (latitude and longitude).

OSM ways have an ordered list of *way nodes* referencing the *child nodes* of
the way. Any way that has a node as a child node is called a *parent way* of
that node. Nodes can have zero or more parent ways.

OSM relations have an ordered list of zero or more *members* which can
reference nodes, ways, or other relations. Those referenced objects are called
*children* of that relation. The relation is then called a *parent relation*.
OSM objects can have zero or more parent relations.

You can think of the OSM objects being arranged in the form of an upside-down
tree:

```
              relation                         parent
               /\    \                           /\
              /  \    \                          ||
             /    \    \                         ||
          way      way  \                        \/
         / | \       |\  \                     child
        /  |  \      | \  \
       /   |   \     |  \  \
     node node node node node
```

At the bottom are the nodes supporting the ways supporting the relations.
This is a simplified view, of course, but it helps with understanding the
following terminology:

Children of ways and relations and parents of any OSM objects are called
*dependent* objects. So dependency works in both ways. From nodes to parent
ways and from OSM objects to parent relations (*upwards dependency*) as well
as from ways to child nodes and relations to members (*downwards dependency*).

(Because relations can contain other relations as members, the tree is really a
graph, possibly even containing cycles. But osm2pgsql does not handle relation
members of type relation anywhere, so this doesn't come into play here.)

Some further definitions for this document: *input nodes* are nodes read from
one of the input files, the same goes for *input ways* and *input relations*.

## Preliminary Observations

Some OSM objects stand on their own (such as a node tagged as a restaurant or
so), but in many cases several OSM objects are needed to make up a complete
real-world feature. There is still one main object that holds the tags for
the feature, but dependent objects add details such as the geometry of the
feature. Without the dependent objects the data is incomplete.

As mentioned we rely on OSM files always being ordered nodes first, then ways,
then relations. So we are certain that

* we see all children of ways before we see the parent way. This means we
  have seen all locations of the nodes and can therefore assemble the geometry
  of the way from them.
* we have seen all node and way children of relations before we see the
  relation (though not necessarily all children of type relation). This
  means we can usually build the geometry of the relation from their members.

But there are also some information we don't have:

* For all nodes we are not sure whether they are children of a way (or
  several).
* For all objects we are not sure whether they are children of a relation.

## Create vs. append mode

Osm2pgsql can run in either *create mode* (the default, or option `--create`)
or in *append mode* (option `--append`).

In create mode an empty database is initialized with some tables and a normal
OSM file is processed. Because we have no other information than what's in the
OSM file, the file should be *reference complete*, i.e. all children of ways
and relations should be in the file, though osm2pgsql will keep working when
children are missing, possibly generating incomplete geometries.

In append mode an existing database is updated based on OSM change files
(`.osc`). Change files only contain the changed objects themselves but not
any dependent objects (unless they have also changed). So osm2pgsql has to
supplement the information from the change file with information it already
has. This is where the object store comes in.

## The Object Store

Because of the missing information mentioned in the "Preliminary Observations"
section and because OSM change files only contain objects that have changed,
but not any dependent objects, we need to store all OSM objects and the
relationship between those objects in an *object store*. Osm2pgsql provides
this object store (often called "middle").

The first time an OSM object is read, it is stored in the object store. And
every time a new version of the object is read, the object in the store is
updated. Whenever the object is needed again as dependent object of some other
object that we are currently processing, it is retrieved from the object store.

The object store only stores the most recently seen version of any object.
Usually this is the newest version (unless you are reading an older change
file).

Osm2pgsql needs to store the location of all nodes, by default it will store
them in the object store in the database. Instead it can use a so-called
flat node file, which is much more efficient for whole planet imports or
large extracts.

## The Dependency Manager

The dependency manager makes sure that all changes in input data are propagated
to the right places.

The dependency manager will
* find parent ways and relations for all changed nodes
* find parent relations for all changed ways.

Note that for deleted objects no explicit processing of parent objects is done,
because when an object is deleted parent objects must necessarily change also
and the changed versions of those parent objects will be in the same change
file as the deleted object.

Currently dependencies between relations are not taken into account, i.e.
changes in relation members that are themselves relations don't trigger
processing of the parent relation. This might change in future versions of
osm2pgsql.

## Assembling Geometries

A rendering database wouldn't be useful without the geometries of the data.

For nodes this is easy. They contain a location so we can add them as *Point*
geometry to the database.

For ways the geometry is either a *LineString* or a *Polygon* depending on the
tags. In either case we need the locations of the child nodes to assemble
the geometry.

Depending on the tags, relations can have different types of geometries. For
osm2pgsql these are usually *MultiPolygons* or *LineStrings* created from the
geometry of member ways which in turn are created from the location of their
child nodes, but other types of geometries are possible with the flex output.

As we have seen earlier, in a normal OSM file the location of all nodes is
available before we need them for the ways and all ways are complete before we
see the relations. So in import mode, it is always possible to assemble the
geometries from the data that we already have. In append mode, any missing data
is supplied by the object store instead.

The assembly of geometries is done by osm2pgsql in the background. In a way, it
lets you pretend that not only nodes, but ways and relations come with a
geometry. Osm2pgsql will figure out behind the scenes what other objects it
needs for assembling the geometries and does everything for you. It will also
do this correctly in append mode. The following section describe this in more
detail.

## Processing in Stages

Osm2pgsql does its data processing in stages. In each stage certain objects
are processed and certain information is remembered for further stages. We
always try to process as much information as possible as early as possible
and remember only what is needed.

In most cases there are only two processing stages, called *stage 1a* and
*stage 1b*. We'll later see that there is a special case which adds *stage 1c*
and *stage 2*, but lets ignore this for now.

### Stage 1a in Create Mode

The input file or files are read. If there are multiple files they are read
simultaneously. The OSM objects in the files are always fed through the
processing pipeline in the correct order, first nodes ordered by id, then ways,
then relations.

Each node, way, and relation is fed in order to the middle for storage and
the the output for processing.

### Stage 1a in Append Mode

The input file or files are read. If there are multiple files they are read
simultaneously. The OSM objects in the files are always fed through the
processing pipeline in the correct order, first nodes ordered by id, then ways,
then relations.

**[A]** Every input node is read and
* **[A.M]** delivered to the middle for storage
* **[A.O]** delivered to the output for processing
* **[A.D]** delivered to the dependency manager which stores the node id

**[B]** After all input nodes are processed and before the first input way is
processed the dependency manager requests from the middle the ids of all parent
ways and all parent relations of all the node ids it has stored in [A.D]. These
are kept for later.

**[C]** Then every input way is read and
* **[C.M]** delivered to the middle for storage
* **[C.O]** delivered to the output for processing
* **[C.D]** delivered to the dependency manager which stores the way id

**[D]** After all input ways are processed and before the first input relation
is processed the dependency manager requests from the middle the ids of all
parent relations of all the way ids it has stored in [C.D]. These are merged
with the parent relations of the nodes found in [B] and kept for later. It
removes from the list of node parent ways it has stored in [B] all input ways
it has already processed in [C].

**[E]** Then every input relation is read and
* **[E.M]** delivered to the middle for storage
* **[E.O]** delivered to the output for processing
* **[E.D]** delivered to the dependency manager which stores the relation id

**[F]** After all input relations are processed the dependency manager removes
from the list of (node or way) parent relation ids assembled in [B] and [D] all
input relations it has already processed in [E].

### Stage 1b (Append Mode Only)

We now get the list of all parent ways and relations from the dependency
manager (*pending ways* and *pending relations*) and sends them to the output.
This is usually done in multiple threads. Then the list of pending ways and
relations is cleared.

## Getting Information from One Object to Another

So far we have propagated only geometry information from one object to another.
But sometimes it can be useful to have tags or other information propagated
from one object to another. Currently there is one special case that osm2pgsql
supports where this is done: Propagating information from relations to their
member ways. (Future versions of osm2pgsql might support additional functions.)

Sometimes the tags of a parent relation would be useful when rendering the
members. An example are relations of type `route`, like bicycle or bus routes
where you want to draw route numbers or symbols on the member ways.

The flex backend has special support for this use case. The user has to write
some additional Lua code to use this:

The user must implement the `osm2pgsql.select_relation_members()` function in
their Lua config to mark member ways for reprocessing. The function is called
with a relation as its only parameter, it returns a Lua table with the
information about which members are *marked*, i.e. they need to be reprocessed.
Note that unlike the `process_relation()` function, the
`select_relation_members()` function is also called for deleted relations!

If this function is defined, there is an additional *stage 1c* and *stage 2*,
run in create and append mode.

Unlike the geometry information which is "magically" propagated by osm2pgsql
from object to object, the user has to decide which information should be
propagated from the relations to the ways and remember that in the Lua config
file.

### Stage 1c: Process Downwards Dependencies

If ways have been marked in stages 1a or 1b, all parent relations of those
ways are processed in stage 1c. This is needed so that the information from
**all** parent relations of those ways is available, not only from the
relations that triggered the marking.

Say if you have this situation:

```
         _relation1 type=route
       _/
   way1_
        \_
         _relation2
       _/
   way2_
        \_relation3
```

Way1 is in relation1 which is a route relation, it is also in relation2 which
is some other kind of relation which doesn't interest us here. Way2 is also
in two relations.

Now lets say that relation1 marked way1 as one of its members and we have taken
tags from relation1 and used it on way1. When a new change comes in and
relation1 has changes, we have to reprocess way1. But to do that we have to
look at relation2, because it might also have contributed information to the
way1. If it has, we have to make this information available to way1. So we
run the `process_relation()` function on relation1 in stage1a or stage1b and,
later, on relation2 in stage1c.

Of course we don't want this process to go on forever, so we are not
reprocessing way2 or relation3. This is accomplished by running
`select_relation_members()` only on relation1, not relation2, so the recursion
stops there.

### Stage 2: Process Marked Ways

In this stage all ways marked in stages 1a and 1b are reprocessed. That means
we...

* delete all entries in the output tables generated from those ways, and
* run the `process_way()` function on all marked ways which will make new
  entries in the database.

## Source Code

If you want to have a look at the source code:
* `src/input.[ch]pp` contains the code to read the input file(s)
* `src/osmdata.[ch]pp` contains code orchestrating the process described above
* `src/dependency-manager.[ch]pp` contains the dependency management

