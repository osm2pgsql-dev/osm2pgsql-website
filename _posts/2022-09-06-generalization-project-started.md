---
layout: post
title: Generalization project started
---

OpenStreetMap has quite a lot of very detailed geodata. That's great for
generating very detailed maps. But it is sometimes not so easy to create
overview maps in smaller map scales and for smaller zoom levels. We can't
see the forest for all the trees.

To solve this a cartographer uses a bunch of techniques, collectively called
*generalization*: You leave out some details, bunch up several smaller things
into one bigger one, or smooth lines that seems overly wiggely when viewed
from afar. There are many more of these techniques.

When generating maps automatically based on osm2pgsql we usually use SQL
queries after importing the data, either in some steps after import, or when
using the data, for instance when rendering tiles. This is not simple to do and
often slow because of the complex processing involved. And if you want to
update your database with changes from OSM you have to figure out how to only
update what's needed.

With all these problems, osm2pgsql could lend a helping hand. This is what the
[generalization project](https://osm2pgsql.org/generalization/) is all about.
We want to implement some of that functionality in osm2pgsql and also make it
easier to access the functionality that the PostgreSQL/PostGIS database already
has through osm2pgsql.

Thanks to the Prototype Fund and the German Federal Ministry of Education and
Research we got a [research
grant](https://prototypefund.de/project/generalisierung-von-openstreetmap-daten-mit-osm2pgsql/)
to work on this project for half a year starting from now, September 2022. See
[this issue](https://github.com/openstreetmap/osm2pgsql/issues/1663) for some
of the details we'll be working on.

