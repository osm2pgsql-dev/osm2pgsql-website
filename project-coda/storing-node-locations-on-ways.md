---
title: Storing Node Locations on Ways
layout: coda
---

The simplest way to store OSM data would be to store nodes with their
locations, attributes, and tags (if any). Then separate from that the ways with
the list of nodes they reference, their attributes and tags. Then relations
with their member references, attributes, and tags.

But there is a different way. Most node locations are only needed when building
way geometries. The nodes have no other purpose than to supply their locations
to the way(s) they are referenced from. More than 97% of nodes have no tags at
all, they only exists to give their location to a way (or relation). So what if
we stored the node locations with the ways they belong to? We'd still have to
store the locations of nodes that have tags (or that are not part of a way)
somewhere else, but that would need two orders of magnitude less space than for
all nodes.

This idea is not completely new. Osmium has support for generating OSM files
that store node locations with the ways. And [Geodesk]({% link
project-coda/others.md %}#geodesk) stores Ids for nodes with tags and the
location for nodes withoout tags in the ways.

## Kinds of Nodes

Lets explore this idea. We'll ignore relations for the time being to make
things simpler. There are three cases:

1. **Tagged nodes**: A node that has at least one tag is an object in its own
   right and we need access to it. We need to store this node in a way that we
   can access it quickly by its id.
2. **Geometry nodes**: Nodes that have no tags are only there to supply their
   location to the way(s) they are a member of. Most nodes are in exactly one
   way, some are in two or more. On average a node is in about 1.2 ways.
3. **Orphan nodes**: Nodes without tags that are not attached to anything else
   are superfluous. That can happen due to a mapping error or an incomplete
   deletion. We have to take this case into account, but orphan nodes should be
   cleaned up anyway, so there shouldn't be that many in normal operation.

For tagged nodes nothing changes compared to the "simple" storage model. The
main difference is that we need to store less then 3% of the nodes, the data
structure becomes much smaller.

For geometry nodes we can store the node locations with the ways. At first it
seems that storing the location needs even more space compared to the simple
model, because we have to store locations on average 1.2 times instead of only
1 time. But nodes in ways are usually near each other, so we can use delta and
varint encoding to save some space. Locations of consecutive nodes can also be
delta and varint encoded (the PBF format does this) so it will not be a huge
win probably, but on the whole it probably means we need the same amount of
space for storage either way.

There shouldn't be many orphan nodes, so we can probably ignore them in regards
to the amount of space they will need. (As I am writing this there are about
1.1 million orphan nodes.)

## Why this Model Might Help

So the model seems to not save us any space. Why does it make sense? It doesn't
save us much space for storing the actual node locations themselves, but it
could save us same space somewhere else: In the indexes. We'll always need some
kind of index that helps us find the node entry in the "node database". If we
only store 3% of the nodes there, that index will also be massively smaller. On
the other hand: We already have an index that tells us in which way(s) a node
is (because we need that index to find changed ways when a node changes). And
we need a way to find a way by its id, but that index doesn't change, because
there are the same number of way entries in the "way database" So on the whole
we should be saving quite a lot of space for the "index" structure for node
access.

Of course this change doesn't come for free. There are several effects:

1. When we need the location of a geometry node, we'll need to find one way
   this node is in, decode the locations for alle the nodes in that way and
   pull out that node location. This is more expensive than just looking at
   single node's location. On the other hand, that's a query we don't do that
   often. In the normal course of events we only need that node location in the
   context of the way and together with all the other node locations. In that
   case we save quite a bit of effort, because we already have all data in one
   spot.

2. Updates of nodes become much more expensive. We have to find all ways the
   nodes are a member of and change those way entries. And when a node changes
   its status from being a tagged node to geometry node or orphan node or the
   other way around, we'll have to handle all those cases properly. Data
   structures will become more complex and more changes can possibly also lead
   to more bloat. So it might be that in the end all of this is not worth it.

## Relations

Before we can end these musings we need to bring relations back in. There are
only about 23 million node members of relations. Compared to the 10 billion
nodes we have or even the 290 million tagged nodes, this is small fry.

What are these nodes? About 11 million are stops in `route` or
`public_transport` relations, they all have tags. Over 6 million are `house`
members of `associatedStreet` relations, they all have tags. So a vast majority
of member nodes have tags anyway. Of all the member nodes, only the about 2
million `via` nodes of `restriction` relations have probably no tags. So it
doesn't make much sense to do any special processing for member nodes. We'll
all just put them into the *tagged nodes* pile and store them as such even if
they don't have any tags.

When processing relations we still build the geometry by looking up the
location of member ways as in the simple case. For way members, all node
locations are available in the way so we save one level of indirection.

## Orphan Nodes

A side note: Structuring the database like this gives us easy access to the
list of orphan nodes. All nodes without tags in the "node database" are either
referenced from relations or orphan nodes. It would be relatively easy to find
all orphan nodes and display them so that they can be cleaned up.

