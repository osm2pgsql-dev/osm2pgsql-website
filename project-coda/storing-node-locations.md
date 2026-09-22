---
title: Storing Node Locations
layout: coda
---

Naive storage for node locations (using the flat node format) needs currently
about 105 GiB. A bzip2 of that needs about 80 GB, saving 30%. So there is some
space to be gained here. We also know of the [Imposm3 coords cache]({% link
project-coda/imposm.md %}) which needs about 60 GiB, even less.

Reducing this to 60 GiB or below is not only important for the disk space
saved, but also rather important for quick access. Currently a planet import
with osm2pgsql and the flat node file really needs a machine with 128 GB RAM,
it runs considerably slower with only 64 GB of RAM. This is due to the about
1.3 billion way nodes that need to be looked up to get the geometry of all the
ways. If we can reduce this enough it might be feasible again to run osm2pgsql
with a planet on a machine with 64 GB RAM.

Osm2pgsql already uses a more efficient format for node locations in RAM, it is
used for non-slim imports. In this mode, blocks of 32 node ids and their
locations are stored with delta and varint-encoding. This is essentially the
same format as used by Imposm3. As long as most of the blocks are mostly
filled, this is a very efficient format, but - worst case - with only a single
node per block we need to store 1 byte for the number of nodes, plus 1 bytes
for the id (stored as offset to the first id in this block which is known) and
8 bytes for the location.

What makes this block-based format efficient is that empty blocks don't need to
be stored at all. Nodes next to each other in id space are often next to each
other geographically, this helps with making this format work well on small
extracts also.

There is a trade-off in this block-based format: Larger blocks are better for
compression, smaller blocks are quicker to decode when accessing single node
locations. This trade-off can be mitigated somewhat using a cache of recently
used blocks due to the geographic closeness of ids.

When we have the final implementation, we should experiment with various block
sizes to determine the best one for our needs.

## Static vs. dynamic block sizes

There are two ways we can store the data in blocks:

With *static blocks* all blocks have the same number of slots to put Locations
in, for instance 32 locations of 32 specific nodes. Some of the slots will be
empty if the associated node doesn't exists. Using static blocks is easy,
because we know exactly which block a specific node id is in, but it wastes
some space, because some blocks will only contain a single node's location
or locations for very few nodes which makes the delta encoding not work so
well.

With *dynamic blocks* each blocks can contain a variable number of node
locations. During import we fill them to some maximum number of node locations,
but if later on something changes, we might delete nodes or add nodes, so the
number of entries can change.

Dynamic blocks are only possible if the underlying storage can find an object
based on the id even if the object is not stored under that id but a smaller
one. Typical key-value-stores support this, because they store objects in key
order and allow access through an iterator. Getting an object involves asking
for an interator for that key position, you get back one that points to the
nearest previous key which is the one that contains the block of data with
the key you are actually interested in.

Dynamic blocks seem to work well with OSM data, because node locations
occasionally change and sometimes nodes are deleted, but it doesn't happen
often that new nodes are added except nodes "at the end", i.e. new nodes have
ids larger than any nodes before them, so they are added at the end of the
store. New nodes between existing nodes only happen in few cases, for instance
if a change that deleted those nodes is reverted. So in normal processing it
doesn't happen that often that a block that started out small will get so many
node locations added that it becomes slow to use.

But there is another ting to take into account: How are the node locations
actually stored inside that block? For static blocks we can use a bit map at
the beginning which tells us for which nodes we actually have data. Then the
varint and delta-encoded node locations. For dynamic blocks we need to store
the actual node ids (also delta-encoded) to figure out which nodes we have
locations for. I tried implementing both solutions (with some variations) and
tested it with a planet file and various extracts. As expected for small
extracts the dynamic blocks work better, we need 10% to 30% less space then for
static blocks. But the larger the extract the more this changes. For the
Germany extract we reach the "break-even" point, the planet needs about 15%
more space with dynamic blocks than with static blocks. If we consider that for
small extracts even large percentual savings only amount to a few Megabytes,
but for the planet the small percentual savings amount to 8 Gigabytes of data,
we can see that it makes sense to go with the static blocks.

