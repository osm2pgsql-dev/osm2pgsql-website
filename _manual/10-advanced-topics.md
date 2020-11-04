---
chapter: 10
title: Advanced Topics
---

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
Use the `--disable-parallel-indexing` option to build all indexes one after
the other.

{% include_relative options/advanced.md %}

