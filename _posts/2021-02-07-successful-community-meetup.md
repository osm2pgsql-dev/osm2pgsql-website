---
layout: post
title: Successful Community Meetup
author: Jochen Topf
---

Last week we had our first virtual osm2pgsql community meetup. There was quite
a bit more interest than we had anticipated. 16 developers and users talked
about plans and ideas and many questions could be answered.

I started the meeting with a short intro about the development and
documentation work we did in the last year, talked about where we are at the
moment, and where our [current development
priorities](https://osm2pgsql.org/contribute/road-map.html) are.

After the intro we had a wide-ranging discussion about existing and missing
features in osm2pgsql. One hot topic were geometry transformations and
computing of derived geometries like centroids, merged geometries and
simplified geometries. This is high on our list of things to do, but before
many of these features can be implemented some ground-work needs to be done
cleaning up the geometry-related code.

Other topics were: tile expiry, multithreading, performance of osm2pgsql and
PostgreSQL, docker scripts, connecting to different types of databases, better
documentation, testing strategies, and many more.

The meeting showed that we have a diverse community with widely differing use
cases. Some people use osm2pgsql more for ad-hoc imports of small data extracts
to visualize in QGIS or do complex postprocessing on. Others use it to run
planet-wide and minutely updated tile servers.

I hope the users got their questions answered and we developers certainly got
some good ideas and suggestions from the community. One question that was
discussed is how to best keep an osm2pgsql database up to date. There are
several existing solutions but none of them is really easy to use, so Sarah
wrote a new pyosmium-based script geared towards use with osm2pgsql, the [pull
request](https://github.com/openstreetmap/osm2pgsql/pull/1411) is currently in
review.

*Jochen Topf*

