---
chapter: 1
title: Introduction
---

Osm2pgsql is used to import OSM data into a PostgreSQL/PostGIS database for
rendering into maps and many other uses. Usually it is only part of a complex
toolchain, other software is needed that do that actual rendering (i.e. turning
the data into a map), deliver the maps to the user etc.

Osm2pgsql is a fairly complex piece of software and it interacts with the
database system and other pieces of the toolchain in complex ways. It will
take a while until you get some experience with it. It is strongly recommended
that you try out osm2pgsql with small extracts of the OSM data, for instance
the data for your city. Do not start with importing data for the whole planet,
it is easy to get something wrong and it will break after working for hours
or days. You can save yourself a lot of trouble doing some trial runs starting
with small extracts and working your way up, observing memory and disk usage
along the way.

It helps to be familiar with the [PostgreSQL](https://postgresql.org/) database
system and the [PostGIS](https://postgis.net/) extension to it as well as the
[SQL](https://en.wikipedia.org/wiki/SQL) database query language.

