---
chapter: 10
title: Advanced Topics
---

### Notes on Memory Usage

Importing an OSM file into the database is very demanding in terms of RAM
usage. Osm2pgsql and PostgreSQL are running in parallel at this point and both
need memory. You also need enough memory for general file system cache managed
by the operating system, otherwise all IO will become too slow.

PostgreSQL blocks at least the part of RAM that has been configured with the
`shared_buffers` parameter during PostgreSQL tuning and needs some memory on
top of that. (See [Tuning the PostgreSQL
Server](#tuning-the-postgresql-server)). Note that the [PostgreSQL
manual](https://www.postgresql.org/docs/current/runtime-config-resource.html){:.extlink}
recommends setting `shared_buffers` to 25% of the memory in your system, **but
this is for a dedicated database server**. When you are running osm2pgsql on
the same host as the database, this is usually way too much.

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

When you are running out of memory you'll sometimes get a `bad_alloc` error
message. But more often osm2pgsql will simply crash without any useful message.
This is, unfortunately, something we can not do much about. The operating
system is not telling us that there is no memory available, it simply ends
the program. This is due to something called "overcommit": The operating
system will allow the program to allocate more memory than there is actually
available because it is unlikely that all programs will actually need this
memory and at the same time. Unfortunately when programs do, there isn't
anything that can be done except crash the program. Memory intensive programs
like osm2pgsql tend to run into these problems and it is difficult to predict
what will happen with any given set of options and input files. It might run
fine one day and crash on another when the input is only slightly different.

Note also that memory usage numbers reported by osm2pgsql itself or tools such
as `ps` and `top` are often confusing and difficult to interpret. If it looks
like you are running out of memory, try a smaller extract, or, if you can, use
more memory, before reporting a problem.

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

### Using Database While Updating

To improve performance osm2pgsql uses several parallel threads to import or
update the OSM data. This means that there is no transaction around all
the updates. If you are querying the database while osm2pgsql is running, you
might be able to see some updates but not others. While an import is running
you should not query the data. For updates it depends a bit on your use case.

In most cases this is not a huge problem, because OSM objects are mostly
independent of one another. If you are

* writing OSM objects into multiple tables,
* using two-stage processing in the Flex output, or
* doing complex queries joining several tables

you might see some inconsistent data, although this is still rather unlikely.
If you are concerned by this, you should stop any other use of the database
while osm2pgsql is running. This is something that needs to be done outside
osm2pgsql, because osm2pgsql doesn't know what else is running and whether and
how it might interact with osm2pgsql.

Note that even if you are seeing inconsistent data at some point, the moment
osm2pgsql is finished, the data will be consistent again. If you are running a
tile server and using the expire functionality, you will, at that point,
re-render all tiles that might be affected making your tiles consistent again.

### Clustering by Geometry

Typical use cases for a database created by osm2pgsql require querying the
database by geometry. To speed up this kind of query osm2pgsql will by default
cluster the data in the output tables by geometry which means that features
which are in reality near to each other will also be near to each other on
the disk and access will be faster.

*Version >=1.7.0*{:.version} If a table has multiple geometry columns,
clustering will always be by the first geometry column.

This clustering is achieved by ordering and copying each whole table after
the import. This will take some time and it means you will temporarily need
twice the disk space.

When you are using the [flex output](#the-flex-output), you can disable
clustering by setting the `cluster` table option to `no` (see the
[Advanced Table Definition](#advanced-table-definition) section).

