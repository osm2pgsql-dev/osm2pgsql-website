---
chapter: 2
title: System Requirements
---

### Operating System

Osm2pgsql works on Linux, Windows, macOS, and other systems. Only 64bit systems
are supported.

Osm2pgsql is developed on Linux and most of the developers don't have
experience with running it on anything but Linux, so it probably functions best
on that platform. This documentation is also somewhat geared towards Linux
users. That being said, we strive to make the software work well on all
systems. Please report any problems you might have.

Read the [installation instructions]({% link doc/install.md %}) for details
on how to install osm2pgsql on your system.

### Main Memory

Memory requirements for your system will vary widely depending on the size of
your input file. Is it city-sized extract or the whole planet? As a rule of
thumb you need at least as much main memory as the PBF file with the OSM data
is large. So for a planet file you currently need at least 64 GB RAM, better
are 128 GB. Osm2pgsql will not work with less than 2 GB RAM.

More memory can be used as cache by the system, osm2pgsql, or PostgreSQL and
speed up processing a lot.

### Disk

You are strongly encouraged to use a SSD (NVMe if possible) for your database.
This will be much faster than traditional spinning hard disks.

Requirements for your system will vary widely depending on
* the amount of data you want to store (city-sized extract or the whole planet?)
* whether or not you want to update the data regularly

See the [Sizing appendix](#sizing) for some ideas on how large a disk you might
need.

### Database Software

You need the [PostgreSQL](https://www.postgresql.org/){:.extlink} database
system with the [PostGIS](https://postgis.net/){:.extlink} extension installed.

Osm2pgsql aims to support all PostgreSQL and PostGIS versions that are
currently supported by their respective maintainers. Currently PostgreSQL
versions 9.6 and above and PostGIS versions 2.5 and above are supported.
(Earlier versions might work but are not tested any more.) PostgreSQL version
11 or above is recommended.

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

Osm2pgsql requires the use of the [Lua](https://www.lua.org/){:.extlink}
scripting language. If available osm2pgsql can also be compiled using the Lua
JIT (just in time) compiler. Use of Lua JIT is recommended, especially for
larger systems, because it will speed up processing.

Security Note: Lua scripts can do basically anything on your computer that the
user running osm2pgsql is allowed to do, such as reading and writing files,
opening network connections etc. This makes the Lua config files really
versatile and allows lots of great functionality. But you should never use a
Lua configuration file from an unknown source without checking it.
{:note}

