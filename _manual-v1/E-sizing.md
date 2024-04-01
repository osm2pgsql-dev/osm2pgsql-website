---
chapter: 24
appendix: E
title: Sizing
---

It is sometimes difficult to figure out how large a machine you need for an
osm2pgsql database import or how long that import will take. This appendix will
give some guidance on that. But remember that each situation is different,
hardware is different, operating systems are different, database versions are
different. And the exact [configuration for the
database](#tuning-the-postgresql-server) and osm2pgsql can play a large role.
So take the numbers here only as some rough first approximations and try it out
yourself.

Here are the numbers for non-updateable (non-slim) imports:

| Input file  | PBF file size |     Import time | Database size | RAM used |
| ----------- | ------------: | --------------: | ------------: | -------: |
| Switzerland |        0.4 GB |     1 to 4 mins |     2 to 3 GB |     3 GB |
| Germany     |          4 GB |   18 to 39 mins |   20 to 30 GB |    10 GB |
| Europe      |         27 GB | 130 to 240 mins | 140 to 180 GB |    60 GB |
| Planet      |         70 GB |  5.5 to 9 hours | 330 to 407 GB |   120 GB |
{:.desc}

Here are the numbers for updateable (slim with flat nodes) imports:

| Input file  | PBF file size |     Import time | Database size |          |
| ----------- | ------------: | --------------: | ------------: | -------: |
| Switzerland |        0.4 GB |     3 to 5 mins |     4 to 5 GB |          |
| Germany     |          4 GB |   20 to 42 mins |   40 to 48 GB |          |
| Europe      |         27 GB | 150 to 240 mins | 260 to 310 GB |          |
| Planet      |         70 GB |   6 to 10 hours | 590 to 730 GB |          |
{:.desc}

Imports were run on a machine with AMD Ryzen 9 3900 12-Core Processor, 128 GB
RAM and NVMe SSDs. The database was tuned according [the chapter on server
tuning](#tuning-the-postgresql-server). These values are from osm2pgsql version
1.7.0 and with PostgreSQL 14 using data from October 2022.

The imports were run with different configurations, using the pgsql output and
the flex output (with LuaJIT disabled) from simple configurations to complex
ones using the openstreetmap-carto style. RAM use is for osm2pgsql itself only,
the database itself also needs memory. For updatable databases RAM use is
always reported to be around the 80 GB needed for mapping the flat node file
into RAM, but that's not the actual memory used, so these numbers are not shown.
