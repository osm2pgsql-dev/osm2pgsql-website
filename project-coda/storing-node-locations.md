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

