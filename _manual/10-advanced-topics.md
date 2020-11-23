---
chapter: 10
title: Advanced Topics
---

### Notes on Memory Usage

Importing on OSM file into the database is very demanding in terms of RAM
usage. Osm2pgsql and PostgreSQL are running in parallel at this point and both
need memory.

PostgreSQL blocks at least the part of RAM that has been configured with the
`shared_buffers` parameter during PostgreSQL tuning and needs some memory on
top of that. (See [Tuning the PostgreSQL
Server](#tuning-the-postgresql-server)).

Osm2pgsql needs at least 2GB of RAM for its internal data structures,
potentially more when it has to process very large relations. In addition it
needs to maintain a cache for node locations. The size of this cache can be
configured with the parameter `--cache`.

When importing with a flatnode file (option `--flat-nodes`), it is best to
disable the node cache completely (`--cache=0`) and leave the memory for the
system cache to speed up accessing the flatnode file.

For imports without a flatnode file, set `--cache` approximately to the size of
the OSM pbf file you are importing. (Note that the `--cache` setting is in
MByte). Make sure you leave enough RAM for PostgreSQL and osm2pgsql as
mentioned above. If the system starts swapping or you are getting out-of-memory
errors, reduce the cache size or consider using a flatnode file.

### Parallel Processing

Some parts of the osm2pgsql processing can run in parallel. Depending on the
hardware resources of you machine, this can make things faster or slower or
even overwhelm your system when too many things happen in parallel and your
memory runs out. For normal operation the defaults should work, but you can
fine-tune the behaviour using some command line options.

Osm2pgsql will do some of its processing in parallel. Usually it will use
however many threads your CPUs support, but no more than 4. For most use
cases this should work well, but you can tune the number of threads used
with the `--number-processes` command line option. (Note that the option is
a bit of a misnomer, because this sets the number of threads used, they are
all in a single process.) If disks are fast enough e.g. if you have an SSD,
then this can greatly increase speed of the "going over pending ways" and
"going over pending relations" stages on a multi-core server. Past 8 threads
or so this will probably not gain you any speed advantage.

By default osm2pgsql starts the clustering and index building on all tables in
parallel to increase performance. This can be a disadvantage on slow disks, or
if you don't have enough RAM for PostgreSQL to do the parallel index building.
PostgreSQL potentially needs the amount of memory set in the
`maintenance_work_mem` config setting for each index it builds. With 7 or more
indexes being built in parallel this can mean quite a lot of memory is needed.
Use the `--disable-parallel-indexing` option to build the indexes one after
the other.

### Handling of Forward Dependencies

Whenever a node changes, osm2pgsql will find all ways and relations that have
this node as a member and reprocess them. Similarly, whenever a way changes,
their parent relations are reprocessed. So osm2pgsql will automatically handle
"forward dependencies" from nodes and ways to their parents. Almost always this
is the behaviour you want.

*Version >= 1.4.0*{: .version} This behaviour can be disabled with the command
line option `--with-forward-dependencies=false`. It is used by Nominatim which
uses the specialized Gazetteer output which doesn't need this behaviour.

