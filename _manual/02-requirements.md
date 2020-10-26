---
chapter: 2
title: System Requirements
---

### Operating System

Osm2pgsql works on
<img class="inline" src="{% link img/linux.png %}"/> Linux,
<img class="inline" src="{% link img/windows.png %}"/> Windows, and
<img class="inline" src="{% link img/apple.png %}"/> macOS.

Osm2pgsql is developed on Linux and most of the developers don't have
experience with running it on anything but Linux, so it will probably works
best there. This documentation is also somewhat geared towards Linux users.
That being said, we strive to make the software work on Windows and macOS as
well. Please report any problems you might have.

Only 64bit systems are supported.

Read the [installation instructions]({% link doc/install.md %}) for details
on how to install osm2pgsql on your system.

### Main Memory

Memory requirements for your system will vary widely depending on the size of
your input file. Is it city-sized extract or the whole planet? As a rule of
thumb you need at least as much main memory as the PBF file with the OSM data
is large. So for a planet file you currently need at least 64 GB RAM. Osm2pgsql
will not work with less than 2 GB RAM.

More memory can be used as cache and speed up processing a lot.

### Disk

You are strongly encouraged to use a SSD (NVMe if possible) for your database.
This will be much faster than traditional spinning hard disks.

Requirements for your system will vary widely depending on
* the amount of data you want to store (city-sized extract or the whole planet?)
* whether or not you want to update the data regularly

### Database Software

You need the [PostgreSQL](https://www.postgresql.org/){:.extlink} database
system with the [PostGIS](https://postgis.net/){:.extlink} extension installed.

Osm2pgsql aims to support all PostgreSQL and PostGIS versions that are
currently supported by their respective maintainers. Currently PostgreSQL
versions 9.6 and above and PostGIS versions 2.2 and above are supported.
PostgreSQL version 11 or above and PostGIS version 2.4 or above is recommended.

In some cases older versions of osm2pgsql have problems with newer database
software versions. You should always run the newest released osm2pgsql version
which should ensure you get any fixes we have done to make osm2pgsql work well
with any PostgreSQL version.

Osm2pgsql does not work with database systems other than PostgreSQL. The
PostgreSQL/PostGIS combination is unique in its capabilities and we are using
some of their special features. We are not planning to support any other
database systems. There are some database systems out there which claim
compatibility with PostgreSQL, they might work or they might not work. Please
tell us if you have any experience with them.

### Lua Scripting Language

Some parts of osm2pgsql require the use of the
[Lua](https://www.lua.org/){:.extlink} scripting language. It is highly
recommended that you use a version of osm2pgsql with Lua support enabled,
because it gives you a much more flexible configuration. If available osm2pgsql
can also be compiled using the Lua JIT (just in time) compiler.

Osm2pgsql can also be compiled without Lua support. In that case the *pgsql*
and *gazetteer* outputs are the only available.

